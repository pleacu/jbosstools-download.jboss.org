@echo off

goto MAIN

:USAGE
echo.
echo Usage: %0 c:\path\to\jbdevstudio-product-universal-*.jar [c:\path\to\jre\bin\java]
echo.
echo Example: %0 c:\temp\jbdevstudio-product-universal-7.0.0.GA-v20130720-0044-B364.jar
echo Example: %0 c:\temp\jbdevstudio-product-universal-7.0.0.GA-v20130720-0044-B364.jar c:\progra~1\java\jre7\bin\java
echo.
goto END

:MAIN
if [%1]==[] goto USAGE

:: Thanks to http://en.wikibooks.org/wiki/Windows_Batch_Scripting#Percent_tilde
:: Want JRE path with no enclosing quotes and no spaces, so use %~s2 instead of %2
set JREPATH=c:\Progra~1\java\jre7\bin\java
if not [%2]==[] set JREPATH=%~s2

:: Install into user home dir, eg., c:\Users\JohnSmith ? 
:: set baseInstallDir=%HOMEDRIVE%%HOMEPATH%
:: Or, install into c:\Program Files
set baseInstallDir=c:\progra~1
:: echo baseInstallDir = %baseInstallDir%

:: Thanks to http://en.wikibooks.org/wiki/Windows_Batch_Scripting#Percent_tilde
:: Want installerJar (with quotes and full path - %1), but want only the filename (minus prefix path and trailing extension) for the dir name - %~n1
set installerJar=%1
set installDir=%~n1
:: echo installDir = %installDir%

:: Thanks to http://en.wikibooks.org/wiki/Windows_Batch_Scripting#Percent_tilde
:: Set installPath using short 8.3 folder names for full compatibility
for %%i in ("%baseInstallDir%\%installDir%") do @set installPath=%%~si
:: echo installPath=%installPath%

:: Create installation script
set installXML=c:\temp\%installDir%.install.xml
:: echo installXML = %installXML%
echo ^<?xml version='1.0' encoding='UTF-8' standalone='no'?^> > %installXML%
echo ^<AutomatedInstallation langpack='eng'^> >> %installXML%
echo ^<com.jboss.jbds.installer.HTMLInfoPanelWithRootWarning id='introduction'/^> >> %installXML%
echo ^<com.izforge.izpack.panels.HTMLLicencePanel id='licence'/^> >> %installXML%
echo ^<com.jboss.jbds.installer.PathInputPanel id='target'^> >> %installXML%
echo ^<installpath^>%installPath%^</installpath^> >> %installXML%
echo ^</com.jboss.jbds.installer.PathInputPanel^> >> %installXML%
echo ^<com.jboss.jbds.installer.JREPathPanel id='jre'/^> >> %installXML%
echo ^<com.jboss.jbds.installer.JBossAsSelectPanel id='as'^> >> %installXML%
echo ^<installgroup^>jbds^</installgroup^> >> %installXML%
echo ^</com.jboss.jbds.installer.JBossAsSelectPanel^> >> %installXML%
echo ^<com.jboss.jbds.installer.UpdatePacksPanel id='updatepacks'/^> >> %installXML%
echo ^<com.jboss.jbds.installer.DiskSpaceCheckPanel id='diskspacecheck'/^> >> %installXML%
echo ^<com.izforge.izpack.panels.SummaryPanel id='summary'/^> >> %installXML%
echo ^<com.izforge.izpack.panels.InstallPanel id='install'/^> >> %installXML%
echo ^<com.jboss.jbds.installer.CreateLinkPanel id='createlink'^> >> %installXML%
echo ^<jrelocation^>%JREPATH%^</jrelocation^> >> %installXML%
echo ^</com.jboss.jbds.installer.CreateLinkPanel^> >> %installXML%
echo ^<com.izforge.izpack.panels.ShortcutPanel id='shortcut'/^> >> %installXML%
echo ^<com.jboss.jbds.installer.ShortcutPanelPatch id='shortcutpatch'/^> >> %installXML%
echo ^<com.izforge.izpack.panels.SimpleFinishPanel id='finish'/^> >> %installXML%
echo ^</AutomatedInstallation^> >> %installXML%

:: Perform headless install
"%JREPATH%" -jar %installerJar% %installXML%

:: Store script inside install folder for reuse
move %installXML% %baseInstallDir%\%installDir%

echo.
echo JBDS Installed to %installPath%\
echo.
echo To run JBDS:
echo.
echo Open folder %installPath%\, then double-click jbdevstudio.bat
echo.

:END
