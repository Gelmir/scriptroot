@ECHO OFF
SET CWD=%CD%
SET "APPDATA_ROOT=C:\Users\Nick\AppData"
CD /D "%APPDATA_ROOT%"
IF EXIST "%APPDATA_ROOT%\qBittorrent_R.7z" DEL /Q "%APPDATA_ROOT%\qBittorrent_R.7z"
"C:\Program Files\7-Zip\7z.exe" a -t7z "%APPDATA_ROOT%\qBittorrent_R.7z" Local\qBittorrent Roaming\qBittorrent -mx9 -mmt=on -mf=on -mhc=on -ms=on -m0=LZMA2
IF EXIST "%APPDATA_ROOT%\Local\qBittorrent" RD /S /Q "%APPDATA_ROOT%\Local\qBittorrent"
IF EXIST "%APPDATA_ROOT%\Roaming\qBittorrent" RD /S /Q "%APPDATA_ROOT%\Roaming\qBittorrent"
"C:\Program Files\7-Zip\7z.exe" x "%APPDATA_ROOT%\qBittorrent_D.7z" -o"%APPDATA_ROOT%"
SET APPDATA_ROOT=
CD /D %CWD%