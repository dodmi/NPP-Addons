' What is this?
' This is a short script to replace Windows Notepad with Notepad++.
' It tries to imitate Notepad's parameter handling
' 
' How to use this file?
' - Place the file on your hard drive
' - Be sure, that notepad++.exe is registered in
' HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths
' This key is used to determine the location of Notepad++.exe
' - Set the script as debugger for notepad.exe
' Navigate to 
' HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe
' Create the String entry "Debugger" and set the value
' wscript.exe "<PathToReplacementScript>\replaceNotepad.vbs"
'
' Where do I get the latest version?
' https://github.com/dodmi/NPP-Addons/tree/master/notepadReplacement
' 
' When was this file updated?
' 2021-04-03

option explicit

' test if the registry key "key" exists
function regKeyExists(key)
    dim objShell
    on error resume next
    
    set objShell = createObject("wScript.shell")
	objShell.regRead(key)
    select case err.number
        case 0: regKeyExists = true
        case else: regKeyExists = false
    end select
    err.clear
    set objShell = nothing
end function

' get the default printer
function getDefaultPrinter()
	dim objWMI, objDefPrinters, objPrinter
	
	set objWMI = GetObject("winmgmts:\\.\root\cimv2")
	set objDefPrinters = objWMI.ExecQuery("Select * from Win32_Printer where Default = 'True'")
	for each objPrinter in objDefPrinters
		getDefaultPrinter = objPrinter.name
	next
	set objDefPrinters = nothing
	set objWMI = nothing
end function
	
' set the default printer
function setDefaultPrinter(printerName)
	dim objWMI, objPrinters, objPrinter
	
	set objWMI = GetObject("winmgmts:\\.\root\cimv2")
	set objPrinters = objWMI.ExecQuery("Select * from Win32_Printer Where Name = '"& printerName &"'")
	for each objPrinter in objPrinters
		objPrinter.SetDefaultPrinter()
	next
	set objPrinters = nothing
	set objWMI = nothing
end function

dim wsShell, wsFSO, baseKey, editorKeys, curEditorKey, editor, editorPath, i, commonArgs, args, curArg, cmd, defaultPrinter, waitForExit

' specify search keys for path to editors like UEdit32/64 or NotePad++
baseKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\"
editorKeys = array("UEdit32.exe","UEdit64.exe","notepad++.exe")
' put any general command line arguments (e.g. /fni) for UEdit here, must start with a space:
commonArgs = ""
' should the script wait until the editor exits
waitForExit = False

args = ""
' searching for editors in Registry
set wsShell = createObject("wScript.shell")
for i = 0 to UBound(editorKeys)
	curEditorKey = baseKey & editorKeys(i) & "\"
	if (regKeyExists(curEditorKey)) then 
		editorPath = wsShell.regRead(curEditorKey)
		editor = editorKeys(i)
	end if
next
if (editorPath = "") then
	wScript.echo "Neither UltraEdit nor Notepad++ were found on your system!"
	set wsShell = nothing
	wScript.quit
end if

for i = 1 to wScript.arguments.count - 1
	curArg = wScript.arguments(i)
' handle parameters for better compatibility
	select case editor
		case "notepad++.exe"
			if (StrComp(curArg, "/p", 1) = 0) then
				curArg = ""
				commonArgs = commonArgs & " -noPlugin -quickPrint"
			end if
			if (StrComp(curArg, "/pt", 1) = 0) then
				defaultPrinter = getDefaultPrinter()
				setDefaultPrinter(wscript.arguments(i+2))
				curArg = wscript.arguments(i+1)
				commonArgs = commonArgs & " -noPlugin -quickPrint"
				waitForExit = True
				if (StrComp(curArg, "") <> 0) then
					if (InStr(curArg, " ") = 0) then
						args = " " & curArg
					else
						args = " """ & curArg & """"
					end if
				end if				
				exit for
			end if
	end select
' if parameter contains a space, surround with " else just add to the list
	if (StrComp(curArg, "") <> 0) then
		if (InStr(curArg, " ") = 0) then
			args = args & " " & curArg
		else
			args = args & " """ & curArg & """"
		end if
	end if
next
' if " is not in arg string, test if the complete string matches a valid file
if (InStr(args, """") = 0) then
	set wsFSO = createObject("Scripting.FileSystemObject")
	if (wsFSO.FileExists(lTrim(args))) then
		args = " """ & lTrim(args) & """"
	end if
	set wsFSO = nothing
end if

' If something does not work as expected, uncomment this line for debug purposes
' wScript.echo """" & editorPath & """" & commonArgs & args

wsShell.run """" & editorPath & """" & commonArgs & args, 0, waitForExit
if (StrComp(defaultPrinter, "") <> 0) then SetDefaultPrinter(defaultPrinter)

set wsShell = nothing
wScript.quit