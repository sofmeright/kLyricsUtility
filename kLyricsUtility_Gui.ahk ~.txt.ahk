OnExit, ExitSequence
Gui, +Resize +MinSize600x300
Gui("Add", "Tab2", "vLyricTab", "Downloader|Browser|View|Settings") ;|Settings ;Add feature later...
Gui("Tab", "Downloader")
GuiAdd_TextEdit("URL:" . A_Tab, UrlLyricsHtml, "UrlLyricsHtml", 2)
Gui("Add", "Text", "x20 y+0", "")
Gui, Font, Underline
Gui("Add", "Text", "cBlue x20 y+0 gInternet_SongLyrics vInternet_SongLyrics", "Click here to visit SongLyrics.com for yourself.")
Gui, Font, Norm
Gui("Add", "Text", "x20 y+0 w500", "`nNote: When using the method below it is important to make sure you spell correctly. `nIf you have any further troubles you should assume that your lyric is not on SongLyrics.com`n")
GuiAdd_TextEdit("Artist:" . A_Tab, SongLyricsArtist, "SongLyricsArtist", 2, "gSongLyricsByInfo")
GuiAdd_TextEdit("Album:" . A_Tab, SongLyricsAlbum, "SongLyricsAlbum", 2, "ReadOnly gSongLyricsByInfo")
GuiAdd_TextEdit("Song:" . A_Tab, SongLyricsSong, "SongLyricsSong", 2, "gSongLyricsByInfo")
Gui("Add", "Button", "Default x" . XLevel(1) . " gDownloadLyrics vButtonDownload", "Get Lyrics")
Gui("Tab", "Browser")
Gui("Add", "ListView", "x" . XLevel(2) . " y+" . GuiMarginY . " gGuiSaveData vLyricsSelect Sort", "Artist|Album|Song")
Gui("Add", "Button", "x" . XLevel(1) . " gViewLyrics vButtonView", "View Lyrics")
Gui("Tab", "View")
GuiAdd_TextEdit("Artist:" . A_Tab,, "Artist", 2)
GuiAdd_TextEdit("Album:" . A_Tab,, "Album", 2)
GuiAdd_TextEdit("Song:" . A_Tab,, "Song", 2)
GuiAdd_TextEdit("Lyrics:" . A_Tab,, "Lyrics", 2, "r10 VScroll")
Gui("Add", "Button", "x" . XLevel(1) . " gEditLyrics vButtonEdit", "Apply Edit")
Gui("Tab", "Settings")
Gui("Add", "Checkbox", "Checked vAutoplay", "Enable Audio Autoplays")
Gui("Add", "Button", "gAudioStop", "Stop Current Audio")
Gui("Show", , "kLyricsUtility (vSongLyrics.com)")
OnMessage(0x200, "WM_MOUSEMOVE")
GoTo, GuiEndAutoExecute

AudioStop:
Process, Close, Wav.exe
Return

BrowserQue:
LV_Delete()
LyricInfo := {}
Loop, *.sLyrc, , 1
{
	Filename := RegExReplace(A_LoopFileFullPath, "Lyrics\\|.sLyrc", "")
	Loop, Parse, Filename, -
		LyricInfo[A_Index] := A_LoopField
	LV_Add("", LyricInfo[1], LyricInfo[2], LyricInfo[3])
}
LV_ModifyCol()
Return

GuiContextMenu:
If A_GuiControl = LyricsSelect
{
	ListViewSelection := A_EventInfo
	Menu, MyContext, Add, Open, ContextOpen
	Menu, MyContext, Add, Delete, ContextDel
	Menu, MyContext, Show, %A_GuiX%, %A_GuiY%
}
Return

GuiResize:
GuiControl, MoveDraw, LyricTab, % "w" . GuiWorkWidth . " h" . GuiWorkHeight - XLevel(2)
GuiControl, MoveDraw, ButtonDownload, % " y" . GuiWorkHeight - 10
GuiControl, MoveDraw, ButtonView, % " y" . GuiWorkHeight - 10
GuiControl, MoveDraw, ButtonEdit, % " y" . GuiWorkHeight - 10
GuiCtrl_StdWidth("UrlLyricsHtml")
GuiCtrl_StdWidth("LyricsSelect")
GuiCtrl_StdWidth("SongLyricsArtist")
GuiCtrl_StdWidth("SongLyricsSong")
GuiCtrl_StdWidth("Artist")
GuiCtrl_StdWidth("Album")
GuiCtrl_StdWidth("Song")
GuiCtrl_StdWidth("Lyrics")
GuiCtrl_StdHeight("LyricsSelect")
GuiCtrl_StdHeight("Lyrics")
Return
ExitSequence:
Process, Close, Wav.exe
FileDelete, %A_Temp%\Wav.exe
Gui, Destroy
Gui, Font, S11, Comic Sans MS
Gui, Add, Text, xm, The program will exit in approximately 30 seconds.`nPlease consider sharing your thoughts.
Gui, Add, Text, xm, Send me an email: %A_Tab%
Gui, Add, Edit, ReadOnly x+10 yp, %MyEmail%
Gui, Add, Text, cBlue gCopyEntry vMyEmail x+10 yp, %A_Tab% %A_Tab% %A_Tab% %A_Tab%- Add to Clipboard
Gui, Add, Text, xm, Subject: %A_Tab% %A_Tab%
Gui, Add, Edit, ReadOnly x+10 yp, %MessageSubject% ; Since "SongLyrics" contains Song it can trigger a bad resize...
Gui, Add, Text, cBlue gCopyEntry vMessageSubject x+10 yp, %A_Tab%- Add to Clipboard
Gui, Show, , kLyricsUtility - Exiting Program...
Sleep, 7000
ExitApp
Return
CopyEntry:
Clipboard := %A_GuiControl%
MsgBox, 4144, Clipboard Updated!, Information has been successfully copied to the clipboard:`n"%Clipboard%"`nClick OK to continue., 21
Return

WM_MOUSEMOVE()
{
	If A_GuiControl = Internet_SongLyrics
	{
    	Gui, Font, cPurple underline
		GuiControl, Font, %A_GuiControl%
		SetTimer, UndoMouseOverStyle, -1000
	}
}
UndoMouseOverStyle:
Gui, Font, cBlue underline
GuiControl, Font, Internet_SongLyrics
PrevControl:=""
Return

GuiEndAutoExecute: