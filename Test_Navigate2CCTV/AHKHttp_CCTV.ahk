#Persistent
#SingleInstance, force
SetBatchLines, -1
FileRead, ahp, HomePage.html
; ahp=
; (
; <html>
; <title>AHKhttp-server 1.0</title>
; <body>
; <b>Hello World</b><p>
; <a href="https://www.baidu.com/">baidu</a>
; </body>
; </html>
; )
URLList:={}
URLList := IniGetKeys("WebURL.ini", "config" )
; MsgBox % URLList["我"]
paths := {}
Loop, %A_WorkingDir%\*.png	;create a path for all png files in working dir
	paths["/" . A_LoopFileName] := Func("ResourceLoader")
Loop, %A_WorkingDir%\*.mp4	;create a path for all mp4 files in working dir
	paths["/" . A_LoopFileName] := Func("ResourceLoader")
Loop, %A_WorkingDir%\*.css
	paths["/" . A_LoopFileName] := Func("ResourceLoader")
Loop, %A_WorkingDir%\*.js
	paths["/" . A_LoopFileName] := Func("ResourceLoader")
Loop, %A_WorkingDir%\*.jpg
	paths["/" . A_LoopFileName] := Func("ResourceLoader")
Loop, %A_WorkingDir%\*.gif
	paths["/" . A_LoopFileName] := Func("ResourceLoader")
for key, value in URLList
{
	paths["/#" . key] := Func("OpenURL")
}
paths["/"] := Func("HelloWorld")
paths["404"] := Func("NotFound")
paths["/logo"] := Func("Logo")
; paths["/cctv1"] := Func("OpenURL")


server := new HttpServer()
server.LoadMimes(A_ScriptDir . "/mime.types")
server.SetPaths(paths)
server.Serve(8000)
return

Logo(ByRef req, ByRef res, ByRef server) {
    server.ServeFile(res, A_ScriptDir . "/logo.ico")
    res.status := 200
}
ResourceLoader(ByRef req, ByRef res, ByRef server) {	;every png has path registered to this function
	server.ServeFile(res, A_WorkingDir . req.path)
	res.status := 200
}
NotFound(ByRef req, ByRef res) {
	res.SetBodyText("Page not found")
}


HelloWorld(ByRef req, ByRef res) {
    global ahp
	global URLList
	chnl:=Uri.Decode(req.queries["channel"])
	; msgbox %chnl%

	if(chnl)
	{
		TargetURL:= URLList[chnl]
		; MsgBox, % URLList["我"]
		If(TargetURL)
			{
				run, %TargetURL%
			}
		Else
			NotFound(ByRef req, ByRef res)
	}
    res.SetBodyText(ahp)
    res.status := 200
}

OpenURL(ByRef req, ByRef res) {
    res.SetBodyText("get back")
    res.status := 200
	global URLList
    Url_short_name:=SubStr(req.path, 2)  ; remove the first /
	MsgBox %Url_short_name%
	TargetURL:= URLList[Url_short_name]
	If(TargetURL)
		{
			run, %TargetURL%
		}
	Else
		NotFound(ByRef req, ByRef res)
}

IniGetKeys(InputFile, Section )
{
	;msgbox, OutputVar=%OutputVar% `n InputFile=%InputFile% `n Section=%Section% `n Delimiter=%Delimiter%
	KEYSlist:={}
	Loop, Read, %InputFile%
	{
		LineContent:=Trim(A_LoopReadLine)		
		If SectionMatch=1
		{
			If LineContent=
				Continue
			StringLeft, SectionCheck , LineContent, 1
			If SectionCheck <> [
			{
				StringSplit, KeyArray, LineContent , =
				KeyName=%KeyArray1%
				KeyValue=%KeyArray2%
				KEYSlist[KeyName]:=KeyValue
				; If KEYSlist=
				; 	KEYSlist=%KeyArray1%
				; Else
				; 	KEYSlist=%KEYSlist%%Delimiter%%KeyArray1%
			}
			Else
				SectionMatch=
		}
		If LineContent=[%Section%]
			SectionMatch=1
	}
	; MsgBox % KEYSlist["cctv1"]
	return KEYSlist
}

UrlEncode( String )
{
	OldFormat := A_FormatInteger
	SetFormat, Integer, H

	Loop, Parse, String
	{
		if A_LoopField is alnum
		{
			Out .= A_LoopField
			continue
		}
		Hex := SubStr( Asc( A_LoopField ), 3 )
		Out .= "%" . ( StrLen( Hex ) = 1 ? "0" . Hex : Hex )
	}

	SetFormat, Integer, %OldFormat%

	return Out
}
#include, %A_ScriptDir%\AHKhttp.ahk
#include %A_ScriptDir%\AHKSock.ahk