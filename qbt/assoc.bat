@ECHO OFF
SET "QB_EXE=%CD%\qbittorrent.exe"

ECHO.
ECHO Removing old keys

REG DELETE "HKCR\.torrent" /va /f > NUL
REG DELETE "HKCR\qBittorrent" /va /f > NUL
REG DELETE "HKCR\Magnet" /va /f > NUL

ECHO Registering torrent files
REG ADD "HKCR\.torrent" /ve /f /t REG_SZ /d "qBittorrent" > NUL
REG ADD "HKCR\.torrent" /v "Content Type" /f /t REG_SZ /d "application/x-bittorrent" > NUL

REG ADD "HKCR\qBittorrent\Content Type" /ve /f /t REG_SZ /d "application/x-bittorrent" > NUL
REG ADD "HKCR\qBittorrent\DefaultIcon" /ve /f /t REG_SZ /d "\"%QB_EXE%\",1" > NUL
REG ADD "HKCR\qBittorrent\shell" /ve /f /t REG_SZ /d "open" > NUL
REG ADD "HKCR\qBittorrent\shell\open\command" /ve /f /t REG_SZ /d "\"%QB_EXE%\" \"%%1\"" > NUL

ECHO Registering Magnet links
REG ADD "HKCR\Magnet" /ve /f /t REG_SZ /d "Magnet URI" > NUL
REG ADD "HKCR\Magnet" /v "Content Type" /f /t REG_SZ /d "application/x-magnet" > NUL
REG ADD "HKCR\Magnet" /v "URL Protocol" /f /t REG_SZ /d "" > NUL

REG ADD "HKCR\Magnet\DefaultIcon" /ve /f /t REG_SZ /d "\"%QB_EXE%\",1" > NUL
REG ADD "HKCR\Magnet\shell" /ve /f /t REG_SZ /d "open" > NUL
REG ADD "HKCR\Magnet\shell\open\command" /ve /f /t REG_SZ /d "\"%QB_EXE%\" \"%%1\"" > NUL

ECHO.
ECHO DONE
ECHO.
ECHO Following changes were made:
ECHO ====================
REG QUERY "HKCR\.torrent" /s
REG QUERY "HKCR\qBittorrent" /s
REG QUERY "HKCR\Magnet" /s
ECHO ====================