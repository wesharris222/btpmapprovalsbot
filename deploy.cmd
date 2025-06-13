@echo off
setlocal

echo Deployment started for %WEBSITE_SITE_NAME%

:: Detect if this is a Function App (ends with -func)
echo %WEBSITE_SITE_NAME% | findstr /E "-func" >nul
if %ERRORLEVEL% == 0 (
    echo Detected Function App deployment
    
    :: For Function App, deploy only the functions folder contents
    echo Copying functions folder contents to deployment target...
    xcopy /E /Y /I "%DEPLOYMENT_SOURCE%\functions\*" "%DEPLOYMENT_TARGET%"
    
    :: Run npm install in deployment target
    cd /d "%DEPLOYMENT_TARGET%"
    call :ExecuteCmd npm install --production
) else (
    echo Detected Web App deployment
    
    :: For Web App, deploy root folder but exclude functions folder
    echo Copying bot files to deployment target...
    xcopy /Y "%DEPLOYMENT_SOURCE%\*.js" "%DEPLOYMENT_TARGET%"
    xcopy /Y "%DEPLOYMENT_SOURCE%\*.json" "%DEPLOYMENT_TARGET%"
    xcopy /Y "%DEPLOYMENT_SOURCE%\web.config" "%DEPLOYMENT_TARGET%" 2>nul
    
    :: Copy node_modules if it exists
    if exist "%DEPLOYMENT_SOURCE%\node_modules" (
        xcopy /E /Y /I "%DEPLOYMENT_SOURCE%\node_modules" "%DEPLOYMENT_TARGET%\node_modules"
    )
    
    :: Run npm install in deployment target
    cd /d "%DEPLOYMENT_TARGET%"
    call :ExecuteCmd npm install --production
)

echo Deployment completed successfully
goto end

:ExecuteCmd
setlocal
set _CMD_=%*
echo Executing: %_CMD_%
call %_CMD_%
if "%ERRORLEVEL%" NEQ "0" (
    echo Failed exitCode=%ERRORLEVEL%, command=%_CMD_%
    exit /b %ERRORLEVEL%
)
exit /b 0

:end
endlocal
echo Finished successfully.
