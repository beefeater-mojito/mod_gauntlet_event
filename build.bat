@echo off
setlocal

rem Read config
for /f "usebackq tokens=1,* delims==" %%A in ("build.cfg") do (
    set "%%A=%%B"
)

cd /d "%MODKITDIR%"

rem Remove previous archives
del "%MODNAME%-*.zip" 2>nul

tar.exe -acf "%MODNAME%-%VERSION%.zip" scripts script_hooks ui gfx

rem Replace old archive in game folder
del "%GAME_DATA_DIR%\%MODNAME%-*.zip" 2>nul
copy /Y "%MODNAME%-%VERSION%.zip" "%GAME_DATA_DIR%\"

echo Done.