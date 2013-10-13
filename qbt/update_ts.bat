@ECHO OFF
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
SET "PATH=%BUILDROOT%\tx;%PATH%"
CD /D %HOMEPATH%\Documents\GitHub\qBittorrent

:: Get new Translations
tx pull -f -r qbittorrent.qbittorrent_ents
CD /D %CWD%
CALL %SCRIPTROOT%\virgin.bat restore