@echo off & setLocal EnableDelayedExpansion
:: Copyright Conor McKnight
:: https://github.com/C0nw0nk/
:: https://www.facebook.com/C0nw0nk
:: Automatically sets up youtube-dl.exe ffmpeg.exe and aria2c.exe
:: all you need is the batch script it will download the latest versions from their github pages
:: simple fast efficient easy to move and manage

:: Script Settings
echo Input URL or Playlist URL:
set /p input=
set download_path=
set download_url=--yes-playlist "%input%"
set audio_quality=320K
set audio_format=mp3

:: End Edit DO NOT TOUCH ANYTHING BELOW THIS POINT UNLESS YOU KNOW WHAT YOUR DOING!

set root_path="%~dp0"

if "%download_path%" == "" ( goto :set_download_path ) else ( goto :skip_set_download_path )
:set_download_path
del "%TEMP%\%~nx0" 2>nul
for /F "tokens=*" %%A in (%~dp0%~nx0) do (
	if /I %%A == ^set^ download^_path^= (
		echo Set your download Path to downbload music to: [C:\Music] OR [\\networkshare\\Music]
		set /p download_path=
		if not exist "!download_path!" (
			echo Please enter a valid folder path where you want to store your music
			goto :set_download_path
		)
		echo %%A!download_path!>>"%TEMP%\%~nx0"
	) else (
		echo %%A>>"%TEMP%\%~nx0"
	)
)
move /Y "%TEMP%\%~nx0" %~dp0%~nx0 >nul && call "%~dp0%~nx0"
:skip_set_download_path

goto :next_download

:start_exe
youtube-dl.exe --external-downloader aria2c --ignore-errors --format bestaudio --extract-audio -x --audio-format %audio_format% --audio-quality %audio_quality% --output "%download_path%\%%(playlist)s\%%(title)s.%%(ext)s" %download_url%
goto :end_script

goto :next_download
:start_download
set downloadurl=%downloadurl: =%
FOR /f %%i IN ("%downloadurl:"=%") DO set filename="%%~ni"& set fileextension="%%~xi"
set downloadpath="%root_path:"=%%filename%%fileextension%"
(
echo Dim oXMLHTTP
echo Dim oStream
echo Set fso = CreateObject^("Scripting.FileSystemObject"^)
echo If Not fso.FileExists^("%downloadpath:"=%"^) Then
echo Set oXMLHTTP = CreateObject^("MSXML2.ServerXMLHTTP.6.0"^)
echo oXMLHTTP.Open "GET", "%downloadurl:"=%", False
echo oXMLHTTP.SetRequestHeader "User-Agent", "Mozilla/5.0 ^(Windows NT 10.0; Win64; rv:51.0^) Gecko/20100101 Firefox/51.0"
echo oXMLHTTP.SetRequestHeader "Referer", "https://www.google.co.uk/"
echo oXMLHTTP.SetRequestHeader "DNT", "1"
echo oXMLHTTP.Send
echo If oXMLHTTP.Status = 200 Then
echo Set oStream = CreateObject^("ADODB.Stream"^)
echo oStream.Open
echo oStream.Type = 1
echo oStream.Write oXMLHTTP.responseBody
echo oStream.SaveToFile "%downloadpath:"=%"
echo oStream.Close
echo End If
echo End If
echo ZipFile="%downloadpath:"=%"
echo ExtractTo="%root_path:"=%"
echo ext = LCase^(fso.GetExtensionName^(ZipFile^)^)
echo If NOT fso.FolderExists^(ExtractTo^) Then
echo fso.CreateFolder^(ExtractTo^)
echo End If
echo Set app = CreateObject^("Shell.Application"^)
echo Sub ExtractByExtension^(fldr, ext, dst^)
echo For Each f In fldr.Items
echo If f.Type = "File folder" Then
echo ExtractByExtension f.GetFolder, ext, dst
echo End If
echo If instr^(f.Path, "\%file_name_to_extract%"^) ^> 0 Then
echo If fso.FileExists^(dst ^& f.Name ^& "." ^& LCase^(fso.GetExtensionName^(f.Path^)^) ^) Then
echo Else
echo call app.NameSpace^(dst^).CopyHere^(f.Path^, 4^+16^)
echo End If
echo End If
echo Next
echo End Sub
echo If instr^(ZipFile, "zip"^) ^> 0 Then
echo ExtractByExtension app.NameSpace^(ZipFile^), "exe", ExtractTo
echo End If
if [%file_name_to_extract%]==[*] echo set FilesInZip = app.NameSpace^(ZipFile^).items
if [%file_name_to_extract%]==[*] echo app.NameSpace^(ExtractTo^).CopyHere FilesInZip, 4
if [%delete_download%]==[1] echo fso.DeleteFile ZipFile
echo Set fso = Nothing
echo Set objShell = Nothing
)>"%root_path:"=%%~n0.vbs"
cscript //nologo "%root_path:"=%%~n0.vbs"
del "%root_path:"=%%~n0.vbs"
:next_download

if not defined aria2c_exe (
	if %PROCESSOR_ARCHITECTURE%==x86 (
		set downloadurl=https://github.com/aria2/aria2/releases/download/release-1.36.0/aria2-1.36.0-win-32bit-build1.zip
	) else (
		set downloadurl=https://github.com/aria2/aria2/releases/download/release-1.36.0/aria2-1.36.0-win-64bit-build1.zip
	)
	set file_name_to_extract=aria2c.exe
	set delete_download=1
	set aria2c_exe=true
	goto :start_download
)

if not defined youtubedl_exe (
	set downloadurl=https://github.com/ytdl-org/youtube-dl/releases/latest/download/youtube-dl.exe
	set delete_download=0
	set youtubedl_exe=true
	goto :start_download
)

if not defined ffmpeg_exe (
	set downloadurl=https://github.com/C0nw0nk/youtube-dl-concurrent/raw/main/ffmpeg.exe
	set delete_download=0
	set ffmpeg_exe=true
	goto :start_download
)

goto :start_exe
:end_script
echo Complete.
pause
exit
