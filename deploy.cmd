@echo off
setlocal

echo ===================================
echo Deployment started
echo Site Name: %WEBSITE_SITE_NAME%
echo Deployment Source: %DEPLOYMENT_SOURCE%
echo Deployment Target: %DEPLOYMENT_TARGET%
echo ===================================

:: Check if this is a Function App by looking for common Function App environment variables
if defined FUNCTIONS_EXTENSION_VERSION (
    echo Detected Function App deployment (FUNCTIONS_EXTENSION_VERSION is set)
    goto :DeployFunctionApp
)

:: Alternative: Check if site name contains -func
echo %WEBSITE_SITE_NAME% | find "-func" >nul
if %ERRORLEVEL% == 0 (
    echo Detected Function App deployment (site name contains -func)
    goto :DeployFunctionApp
)

:: Otherwise, it's a Web App
echo Detected Web App deployment
goto :DeployWebApp

:DeployFunctionApp
echo.
echo Deploying Function App from functions folder...

:: Clean deployment target first
echo Cleaning deployment target...
if exist "%DEPLOYMENT_TARGET%\*" del /Q "%DEPLOYMENT_TARGET%\*" 2>nul

:: Copy everything from functions folder
echo Copying functions folder contents...
xcopy /E /Y /I /Q "%DEPLOYMENT_SOURCE%\functions\*" "%DEPLOYMENT_TARGET%\"

goto :InstallDependencies

:DeployWebApp
echo.
echo Deploying Web App from root folder...

:: Copy bot files
echo Copying bot files...
copy /Y "%DEPLOYMENT_SOURCE%\bot.js" "%DEPLOYMENT_TARGET%\" 2>nul
copy /Y "%DEPLOYMENT_SOURCE%\index.js" "%DEPLOYMENT_TARGET%\" 2>nul
copy /Y "%DEPLOYMENT_SOURCE%\package.json" "%DEPLOYMENT_TARGET%\" 2>nul
copy /Y "%DEPLOYMENT_SOURCE%\package-lock.json" "%DEPLOYMENT_TARGET%\" 2>nul
copy /Y "%DEPLOYMENT_SOURCE%\web.config" "%DEPLOYMENT_TARGET%\" 2>nul
copy /Y "%DEPLOYMENT_SOURCE%\*.png" "%DEPLOYMENT_TARGET%\" 2>nul

:: Copy node_modules
if exist "%DEPLOYMENT_SOURCE%\node_modules" (
    echo Copying node_modules...
    xcopy /E /Y /I /Q "%DEPLOYMENT_SOURCE%\node_modules" "%DEPLOYMENT_TARGET%\node_modules\"
)

goto :InstallDependencies

:InstallDependencies
echo.
echo Installing npm dependencies...
cd /d "%DEPLOYMENT_TARGET%"
call npm install --production

echo.
echo ===================================
echo Deployment completed successfully
echo ===================================
exit /b 0
