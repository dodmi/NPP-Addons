// What is this?
// This is a short script to replace Windows Notepad with UltraEdit or Notepad++.
// It tries to imitate Notepad's parameter handling
//
// How to use this file?
// - Place the file on your hard drive
// - Be sure, that notepad++.exe is registered in
// HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths
// This key is used to determine the location of Notepad++.exe
// - Set the script as debugger for notepad.exe
// Navigate to
// HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe
// Create the String entry "Debugger" and set the value
// WScript.exe //E:JScript "<PathToReplacementScript>\replaceNotepad.js"
//
// Where do I get the latest version?
// https://github.com/dodmi/NPP-Addons/tree/master/notepadReplacement
//
// When was this file updated?
// 2026-02-20

// Test if registry key "key" exists
function regKeyExists(key) {
    var wsShell = WScript.createObject("WScript.shell");
	try {
		wsShell.RegRead(key);
		return true;
	} catch (Err) {
		return false;
	}
}

// Get default printer
function getDefaultPrinter() {
	var wsWMI = GetObject("winmgmts://./root/cimv2");
	var defPrinter = wsWMI.ExecQuery("Select Name from Win32_Printer where Default = 'True'");
	if (defPrinter.Count > 0) {
		var e = new Enumerator(defPrinter);
		// There is maximum 1 default printer, so nothing to enumerate...
		return e.item().Name;
	}
	return false;
}

// Set default printer
function setDefaultPrinter(printerName) {
	var wsWMI = GetObject("winmgmts://./root/cimv2");
	var printer = wsWMI.ExecQuery("Select * from Win32_Printer Where Name = '" + printerName  + "'");
	if (printer.Count > 0) {
		var e = new Enumerator(printer);
		// There is maximum 1 default printer, so nothing to enumerate...
		e.item().SetDefaultPrinter();
		return true;
	}
	return false;
}

// Specify search keys for path to editors like UEdit32/64 or NotePad++
var baseKey = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\";
var editorKeys = ["UEdit64.exe","UEdit32.exe","notepad++.exe"];
// Put any general command line arguments (e.g. /fni) for UEdit here, must start with a space:
var commonArgs = "";
// Should the script wait until the editor exits
var waitForExit = false;

var defaultPrinter = false;
var args = "";
var editor;
var editorPath;
// Searching for editors in Registry
var wsShell = WScript.createObject("WScript.shell");
for (var i=0; i<editorKeys.length; i++) {
	curEditorKey = baseKey + editorKeys[i] + "\\"
	if (regKeyExists(curEditorKey)) {
		editorPath = wsShell.regRead(curEditorKey);
		editor = editorKeys[i];
	}
}
if (editorPath === "") {
	WScript.echo("Neither UltraEdit nor Notepad++ were found on your system!");
	WScript.quit();
}

for (var i=1; i<WScript.Arguments.length; i++) {
	curArg = WScript.Arguments(i);
// Handle parameters for better compatibility
	switch(editor) {
		case "notepad++.exe":
			switch(curArg.toLowerCase()) {
				case "/p":
					commonArgs += " -noPlugin -quickPrint";
					break;
				case "/pt":
				// "print to" isn't supported in Notepad++, so we change the default printer and use "print"
					commonArgs += " -noPlugin -quickPrint";
					defaultPrinter = getDefaultPrinter();
					// here's the printer to print to
					setDefaultPrinter(WScript.Arguments(i+2));
					waitForExit = true;
					// here's the file to print
					curArg = WScript.Arguments(i+1);
					i = i+2;
				default:
					if (curArg.indexOf(" ") == -1) {
						args += " " + curArg;
					} else {
						args += " \"" + curArg + "\"";
					}
			}
			break;
		default:
			if (curArg.indexOf(" ") == -1) {
				args += " " + curArg;
			} else {
				args += " \"" + curArg + "\"";
			}
	}
}

// If " is not in arg string, test if the complete string matches a valid file
if (args.indexOf("\"") == -1) {
	var wsFSO = WScript.createObject("Scripting.FileSystemObject");
	if (wsFSO.FileExists(args.substring(1))) {
		args = " \"" + args.substring(1) + "\"";
	}
}

// If something does not work as expected, uncomment this line for debug purposes
// WScript.echo("\"" + editorPath + "\"" + commonArgs + args);

wsShell.run("\"" + editorPath + "\"" + commonArgs + args, 0, waitForExit);
if (defaultPrinter) {
	setDefaultPrinter(defaultPrinter);
}

WScript.quit();
