# Customizations for [Notepad++](https://notepad-plus-plus.org/)

## Themes
You'll find some theme files for Notepad++ in the `themes` sub folder. 
They are built upon the `stylers.model.xml` included in Notepad++ 7.8.9 
(and therefore support all languages defined in this version) 
and are based on the [Solarized color palette](https://ethanschoonover.com/solarized/).

### Solarized-reborn and Solarized-light-reborn
Because the Notepad++ distribution already contains a `Solarized` and a `Solarize-light` theme, 
these are named `Solarized-reborn` and `Solarized-light-reborn`.
The main difference is, that these support more languages for syntax highlighting. 

### Solarized-light-blackened
`Solarized-light-blackened` uses a black foreground color for default text. 
I'm using this one for better readability, but it's not sticking strictly to the official Solarized palette.

### How to use custom theme files?
- These files need to be copied to the themes folder in your Nptepad++ config folder (`%AppData%\Notepad++\themes` for default installations)
- (Re)start Notepad++ after copying the files and they should appear in `Settings -> Styles...`

## User defined languages
You'll find some UDL files for Notepad++ in the `UserDefinedLangs` sub folder.

### userDefinedLang-markdown.default.modern.xml
Is the *Markdown* definition file from Notepad++. I've adapted it to use the Solarized color palette.
It matches my `Solarized-light-blackened` theme, but should be ok with any light theme.

### userDefinedLang-logfile.xml
Provides highlighting in *log* files, using the Solarized color palette.
It matches my `Solarized-light-blackened` theme, but should be ok with any light theme.

### How to use custom theme files?
- These files need to be copied to the themes folder in your Nptepad++ config folder (`%AppData%\Notepad++\userDefinedLangs` for default installations)
- (Re)start Notepad++ after copying the files and they should appear in `Languages`