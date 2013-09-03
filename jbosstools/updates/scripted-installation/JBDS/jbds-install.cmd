@echo off

if "%1"=="" goto USAGE
if "%2"=="" goto USAGE

:: c:\Users\JohnSmith
set baseInstallDir=%HOMEDRIVE%%HOMEPATH%
:: echo baseInstallDir = %baseInstallDir%

set JREPATH=%1
set installerJar=%2
set installDir=%installerJar:.jar=%
:: TODO: strip off all leading path segments to just get the filename
:: echo installDir = %installDir%

set installXML=c:\temp\%installDir%.install.xml
echo ^<?xml version='1.0' encoding='UTF-8' standalone='no'?^> > %installXML%
echo ^<AutomatedInstallation langpack='eng'^> >> %installXML%
echo ^<com.jboss.jbds.installer.HTMLInfoPanelWithRootWarning id='introduction'/^> >> %installXML%
echo ^<com.izforge.izpack.panels.HTMLLicencePanel id='licence'/^> >> %installXML%
echo ^<com.jboss.jbds.installer.PathInputPanel id='target'^> >> %installXML%
echo ^<installpath^>%baseInstallDir%\%installDir%^</installpath^> >> %installXML%
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
  :: TODO: why is this not appearing in the generated XML file?
  echo ^<jrelocation^>%JREPATH%</jrelocation^> >> %installXML%
echo ^</com.jboss.jbds.installer.CreateLinkPanel^> >> %installXML%
echo ^<com.izforge.izpack.panels.ShortcutPanel id='shortcut'/^> >> %installXML%
echo ^<com.jboss.jbds.installer.ShortcutPanelPatch id='shortcutpatch'/^> >> %installXML%
echo ^<com.izforge.izpack.panels.SimpleFinishPanel id='finish'/^> >> %installXML%
echo ^</AutomatedInstallation^> >> %installXML%

%JREPATH% -jar %installerJar% %installXML%

ren %installXML% %baseInstallDir%\%installDir%

echo.
echo JBDS Installed to %baseInstallDir%\%installDir%\
echo.
echo To run JBDS:
echo.
echo %baseInstallDir%\%installDir%\jbdevstudio -data c:\temp\workspace-%installDir%
echo.

goto END

:USAGE
echo.
echo Usage: %0 c:\path\to\java\jre\bin\java c:\path\to\jbdevstudio-product-universal-*.jar
echo.
echo Example: %0 c:\Progra~1\java\jre7\bin\java c:\temp\jbdevstudio-product-universal-7.0.0.GA-v20130720-0044-B364.jar
echo.

:END
