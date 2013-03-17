@ECHO OFF
:: Backing up and Restoring virginal ENV VARS
IF "%1" == "" (
    ECHO Mandatory arguments are: [backup^|restore]
    EXIT /B
)

IF /I "%1" == "backup" (
    SET "PATH_OLD=%PATH%"
    
    IF DEFINED INCLUDE (
        SET "INCLUDE_OLD=%INCLUDE%"
    ) ELSE (
        :: Space here
        SET INCLUDE_OLD= 
    )
    
    IF DEFINED LIB (
        SET "LIB_OLD=%LIB%"
    ) ELSE (
        :: Space here
        SET LIB_OLD= 
    )
    
    IF DEFINED LIBPATH (
        SET "LIBPATH_OLD=%LIBPATH%"
    ) ELSE (
        :: Space here
        SET LIBPATH_OLD= 
    )
)
IF /I "%1" == "restore" (
    SET "PATH=%PATH_OLD%"
    
    IF "%INCLUDE_OLD%" == " " (
        :: No space here -> Erase variable
        SET INCLUDE=
    ) ELSE (
        SET "INCLUDE=%INCLUDE_OLD%"
    )
    
    IF "%LIB_OLD%" == " " (
        :: No space here -> Erase variable
        SET LIB=
    ) ELSE (
        SET "LIB=%LIB_OLD%"
    )
    
    IF "%LIBPATH_OLD%" == " " (
        :: No space here -> Erase variable
        SET LIBPATH=
    ) ELSE (
        SET "LIBPATH=%LIBPATH_OLD%"
    )
    
    :: No spaces
    SET INCLUDE_OLD=
    SET LIB_OLD=
    SET LIBPATH_OLD=
)
