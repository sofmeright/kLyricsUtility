;
; AutoHotkey Version: 1.1.05.01
; Language:       English
; Platform:       Windows[7/Vista/XP]
; Author:         Kai <thecodesbykai@gmail.com>
;
; Script Function:
;	Processes Lyrics from SongLyrics and sends the results back to the caller through CopyData.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On


If A_IsCompiled
{
	Process, Wait, kLyricsUtility.exe
	TargetScriptTitle = ahk_pid %ErrorLevel%
}
Else TargetScriptTitle = kLyricsUtility.ahk ahk_class AutoHotkey

If 0<1 ; If no parameter Url was passed then exit.
	ExitApp
param1 := "1", param2 := "2"
If 0=1
	UrlLyricsHtml := RegExReplace(%param1%, """", "")
If 0=2
	UrlLyricsHtml := "http://www.songlyrics.com/" . RegExReplace(%param1%, "[^a-zA-Z0-9]", "-") . "/" . RegExReplace(%param2%, "[^a-zA-Z0-9]", "-") . "-lyrics"
UrlDownloadToFile, %UrlLyricsHtml%, % ReplaceSpChrUrl(UrlLyricsHtml)
FileRead, LyricsHTML, % ReplaceSpChrUrl(UrlLyricsHtml)
FileDelete, % ReplaceSpChrUrl(UrlLyricsHtml)
Song := HTMLInTag(LyricsHTML, "<title>", " LYRICS")
StringUpper, Song, Song, T ; Converts the Song name to title case.
Artist := HTMLInTag(HTMLInTag(LyricsHTML, "<p>Artist: ", "</p>"), """>", "</a>")
Album := RegExReplace(HTMLInTag(HTMLInTag(LyricsHTML, "<p>Album: ", "</p>"), """>", "</a>"), ":")
Lyrics := RegExReplace(DecodeACSII(HTMLInTag(LyricsHTML, "<p id=""songLyricsDiv"" ondragstart=""return false;"" onselectstart=""return false;"" oncontextmenu=""return false;"" class=""songLyricsV14"">", "</p>")), "`;|<br />", "")
If Lyrics contains lyrics at the moment.,Please check the spelling and try again to
	ExitApp
Send_WM_COPYDATA()
Return

DecodeACSII(ASCIIEncText) {
	Loop, 122
		ASCIIEncText := RegExReplace(ASCIIEncText, "&#" . 123 - A_Index, Chr(123 - A_Index))
	Return ASCIIEncText
}
HTMLInTag(HTML, TagHead, TagFoot) {
	TagStart := InStr(HTML, TagHead)
	TagLength := InStr(HTML, TagFoot, False, TagStart) - TagStart
	Return RegExReplace(SubStr(HTML, TagStart, TagLength), TagHead, "")
}
ReplaceSpChrUrl(Url) {
	Return RegExReplace(RegExReplace(Url, ":", "&cln"), "/", "&sls")
}

Send_WM_COPYDATA()  ; ByRef saves a little memory in this case.
; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
{
	Global TargetScriptTitle, Artist, Album, Song, Lyrics
	MusicInfo := "Artist`,Album`,Song`,Lyrics"
	Loop, Parse, MusicInfo, `,
	{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(%A_LoopField%) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; OS requires that this be done.
    NumPut(&%A_LoopField%, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
	wParam := A_Index - 1
    SendMessage, 0x4a, %wParam%, &CopyDataStruct,, %TargetScriptTitle%  ; 0x4a is WM_COPYDATA. Must use Send not Post.
    DetectHiddenWindows %Prev_DetectHiddenWindows%  ; Restore original setting for the caller.
    SetTitleMatchMode %Prev_TitleMatchMode%         ; Same.
	}
}