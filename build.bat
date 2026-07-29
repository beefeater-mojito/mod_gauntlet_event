REM tar.exe acvf mod_gauntlet_events-1.0.zip scripts script_hooks
set "MODNAME=mod_gauntlet_events"
set "VERSION=1.0"

set "MODKITDIR=B:\games\light\BB\bb modding\wip\mod_gauntlet_events"
set "GAME_DATA_DIR=B:\app\Steam\steamapps\common\Battle Brothers\data"

call tar.exe acvf "%MODNAME%-%VERSION%.zip" scripts script_hooks

copy /Y "%MODNAME%-%VERSION%.zip" "%GAME_DATA_DIR%" 