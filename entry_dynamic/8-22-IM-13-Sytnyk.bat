\masm32\bin\ml /c /coff "8-22-IM-13-Sytnyk-lib.asm"
\masm32\bin\Link.exe /out:"8-22-IM-13-Sytnyk-lib.dll" /export:calculateLib /dll "8-22-IM-13-Sytnyk-lib.obj"
\masm32\bin\ml /c /coff "8-22-IM-13-Sytnyk.asm"
\masm32\bin\Link.exe /subsystem:windows "8-22-IM-13-Sytnyk.obj"
8-22-IM-13-Sytnyk.exe