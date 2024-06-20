:: Sets up git for windows systems

:: turn off useless message
@ECHO OFF
cls

:: Update git, if it fails then that means git is not downloaded
git update-git-for-windows && (powershell write-host -back DarkGreen -fore Black Update complete . . .) || (goto :DownloadGit)

:RefreshEnvironment
powershell write-host -back DarkGreen -fore Black Refreshing Environment
:: with the newly installed git, we need to "restart" the environment to access the new commands
:: code from [here](https://stackoverflow.com/a/32420542)
:: RefreshEnv.cmd
:: ================================================================================================
:: Batch file to read environment variables from registry and
:: set session variables to these values.
::
:: With this batch file, there should be no need to reload command
:: environment every time you want environment changes to propagate

echo | set /p dummy="Reading environment variables from registry. Please wait... "

goto main

:: Set one environment variable from registry key
:SetFromReg
    "%WinDir%\System32\Reg" QUERY "%~1" /v "%~2" > "%TEMP%\_envset.tmp" 2>NUL
    for /f "usebackq skip=2 tokens=2,*" %%A IN ("%TEMP%\_envset.tmp") do (
        echo/set %~3=%%B
    )
    goto :EOF

:: Get a list of environment variables from registry
:GetRegEnv
    "%WinDir%\System32\Reg" QUERY "%~1" > "%TEMP%\_envget.tmp"
    for /f "usebackq skip=2" %%A IN ("%TEMP%\_envget.tmp") do (
        if /I not "%%~A"=="Path" (
            call :SetFromReg "%~1" "%%~A" "%%~A"
        )
    )
    goto :EOF

:main
    echo/@echo off >"%TEMP%\_env.cmd"

    :: Slowly generating final file
    call :GetRegEnv "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" >> "%TEMP%\_env.cmd"
    call :GetRegEnv "HKCU\Environment">>"%TEMP%\_env.cmd" >> "%TEMP%\_env.cmd"

    :: Special handling for PATH - mix both User and System
    call :SetFromReg "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" Path Path_HKLM >> "%TEMP%\_env.cmd"
    call :SetFromReg "HKCU\Environment" Path Path_HKCU >> "%TEMP%\_env.cmd"

    :: Caution: do not insert space-chars before >> redirection sign
    echo/set Path=%%Path_HKLM%%;%%Path_HKCU%% >> "%TEMP%\_env.cmd"

    :: Cleanup
    del /f /q "%TEMP%\_envset.tmp" 2>nul
    del /f /q "%TEMP%\_envget.tmp" 2>nul

    :: Set these variables
    call "%TEMP%\_env.cmd"

    echo | set /p dummy="Done"
    echo .
:: ================================================================================================

powershell write-host -back DarkGreen -fore Black Refresh success . . .

:: name and email will be needed to track down who broke the code :P
:Name
cls
echo What is your
echo.
set /p input=Name:
:: setup name
git config --global user.name %input% && (echo Name set to %input%) || (goto :NameError)

set /p input=Email:
:: setup email
git config --global user.email %input%

:: get GitHub link and clone to current directory
:GitClone
set /p input=GitHub link : 
git clone %input% && (powershell write-host -back DarkGreen -fore Black Clone success . . . just a few more steps !!!) || (goto :GitCloneError)

:: get the name of the project and open in VS Code
:: Code refered from [here](https://stackoverflow.com/a/11923818)
for /f "delims=" %%F in ('dir /b /ad /O:-D') do (
    set "filename=%%F"
    goto :SetupGitHub
)

:SetupGitHub
:: empty commit to setup github and git (first time commit and push will ask for sign up)
cd %filename%
cls
powershell write-host -back DarkGreen -fore Black You will need to allow access to GutHub
powershell write-host -back DarkGreen -fore Black Sign in/Sign up from the popup
git commit --quiet --allow-empty -m "Hi !!!"
git push --quiet origin main

:: File created notification
echo.
powershell write-host -back DarkGreen -fore Black Sign in complete . . .
echo.
powershell write-host -back DarkGreen -fore Black You are all set up !!!
powershell write-host -back DarkGreen -fore Black There is a new folder named %filename%. Feel free to relocate it.
echo.

:: end
powershell write-host -back DarkGreen -fore Black Script END . . . proceeding to open project
pause

:: open project
:: if have NetBeans then use NetBeans, if no then use VS Code, if no VS Code then download VS Code
cls
set "projectDir=%CD%"

:: Find NetBeans.exe (since NetBeans does not have command line interface, we have to find the .exe)
:: code from Chat-GPT
for /D %%I in ("%ProgramFiles%\NetBeans-*") do (
    if exist "%%I\netbeans\bin\netbeans" (
        cd /d "%%I\netbeans\bin"
        powershell write-host -back DarkGreen -fore Black P.S. :
        powershell write-host -back DarkGreen -fore Black I highly recommend using Gits built in GUI application to do push pull commit etc . . .
        powershell write-host -back DarkGreen -fore Black Because NetBeans UI is confusing and does not completely support GitHub
        powershell write-host -back DarkGreen -fore Black OR
        powershell write-host -back DarkGreen -fore Black Just switch to VisualStudioCode :P
        git-gui --working-dir "%projectDir%"
        start /B netbeans "%projectDir%"
        timeout 8
        exit /b
    )
)

:: if not found then use VS Code
code %projectDir% && (exit /b) || (goto :DownloadVsCode)

:: =============================== ERROR HANDELING

:: Or download git from the official website [here](https://git-scm.com/download/win)
:DownloadGit
cls
powershell write-host -back DarkGreen -fore Black Git not found . . . Proceeding to download Git
winget install --id Git.Git -e --source winget && (powershell write-host -back DarkGreen -fore Black Download complete . . .) || (goto :InternetError)
goto :RefreshEnvironment

:DownloadVsCode
powershell write-host -back DarkGreen -fore Black VisualStudioCode not found . . .
powershell write-host -back DarkGreen -fore Black Do you want to Download VisualStudioCode ? close this window if you dont
pause
winget install Microsoft.VisualStudioCode

:: Refresh Env to be able to run "code"
powershell write-host -back DarkGreen -fore Black Refreshing Environment
:: with the newly installed git, we need to "restart" the environment to access the new commands
:: code from [here](https://stackoverflow.com/a/32420542)
:: RefreshEnv.cmd
:: ================================================================================================
:: Batch file to read environment variables from registry and
:: set session variables to these values.
::
:: With this batch file, there should be no need to reload command
:: environment every time you want environment changes to propagate

echo | set /p dummy="Reading environment variables from registry. Please wait... "

goto main

:: Set one environment variable from registry key
:SetFromReg
    "%WinDir%\System32\Reg" QUERY "%~1" /v "%~2" > "%TEMP%\_envset.tmp" 2>NUL
    for /f "usebackq skip=2 tokens=2,*" %%A IN ("%TEMP%\_envset.tmp") do (
        echo/set %~3=%%B
    )
    goto :EOF

:: Get a list of environment variables from registry
:GetRegEnv
    "%WinDir%\System32\Reg" QUERY "%~1" > "%TEMP%\_envget.tmp"
    for /f "usebackq skip=2" %%A IN ("%TEMP%\_envget.tmp") do (
        if /I not "%%~A"=="Path" (
            call :SetFromReg "%~1" "%%~A" "%%~A"
        )
    )
    goto :EOF

:main
    echo/@echo off >"%TEMP%\_env.cmd"

    :: Slowly generating final file
    call :GetRegEnv "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" >> "%TEMP%\_env.cmd"
    call :GetRegEnv "HKCU\Environment">>"%TEMP%\_env.cmd" >> "%TEMP%\_env.cmd"

    :: Special handling for PATH - mix both User and System
    call :SetFromReg "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" Path Path_HKLM >> "%TEMP%\_env.cmd"
    call :SetFromReg "HKCU\Environment" Path Path_HKCU >> "%TEMP%\_env.cmd"

    :: Caution: do not insert space-chars before >> redirection sign
    echo/set Path=%%Path_HKLM%%;%%Path_HKCU%% >> "%TEMP%\_env.cmd"

    :: Cleanup
    del /f /q "%TEMP%\_envset.tmp" 2>nul
    del /f /q "%TEMP%\_envget.tmp" 2>nul

    :: Set these variables
    call "%TEMP%\_env.cmd"

    echo | set /p dummy="Done"
    echo .
:: ================================================================================================
powershell write-host -back DarkGreen -fore Black Refresh success . . .
code %projectDir%
exit 

:: Display internet error and exit
:InternetError
powershell write-host -back DarkGreen -fore Black ERROR
powershell write-host -back DarkGreen -fore Black 1. Check your internet connection
powershell write-host -back DarkGreen -fore Black 2. Make sure you have signed in to your Microsoft Store
echo.
powershell write-host -back DarkGreen -fore Black Restart the script after you have meet the above conditions OR download Git from the link below.
powershell write-host -fore Blue https://git-scm.com/download/win
echo.
pause
EXIT

:: Invalid Name
:NameError
powershell write-host -back DarkGreen -fore Black The Name you provided is not valid . . . Try again
goto :Name

:: GitClone error
:GitCloneError
cls
powershell write-host -back DarkGreen -fore Black The GitHub link you provided is not valid . . . Try again
goto :GitClone