#!/bin/bash

baseInstallDir=${HOME}

if [[ $1 ]]; then
  installerJar=$1
  installDir=/home/nboldt/${installerJar//.jar}
  installDir=${installDir##*/}
  installXML=/tmp/${installDir}.install.xml
else
  echo "Usage: $0 ~/tmp/jbdevstudio-product-universal-7.0.0.CR1-v20130713-1554-B358.jar"
  exit 1;
fi

echo "<?xml version='1.0' encoding='UTF-8' standalone='no'?>
<AutomatedInstallation langpack='eng'>
<com.jboss.jbds.installer.HTMLInfoPanelWithRootWarning id='introduction'/>
<com.izforge.izpack.panels.HTMLLicencePanel id='licence'/>
<com.jboss.jbds.installer.PathInputPanel id='target'>
<installpath>${baseInstallDir}/${installDir}</installpath>
</com.jboss.jbds.installer.PathInputPanel>
<com.jboss.jbds.installer.JREPathPanel id='jre'/>
<com.jboss.jbds.installer.JBossAsSelectPanel id='as'>
<installgroup>jbds</installgroup>
</com.jboss.jbds.installer.JBossAsSelectPanel>
<com.jboss.jbds.installer.UpdatePacksPanel id='updatepacks'/>
<com.jboss.jbds.installer.DiskSpaceCheckPanel id='diskspacecheck'/>
<com.izforge.izpack.panels.SummaryPanel id='summary'/>
<com.izforge.izpack.panels.InstallPanel id='install'/>
<com.jboss.jbds.installer.CreateLinkPanel id='createlink'>
<jrelocation>/usr/bin/java</jrelocation>
</com.jboss.jbds.installer.CreateLinkPanel>
<com.izforge.izpack.panels.ShortcutPanel id='shortcut'/>
<com.jboss.jbds.installer.ShortcutPanelPatch id='shortcutpatch'/>
<com.izforge.izpack.panels.SimpleFinishPanel id='finish'/>
</AutomatedInstallation>" > ${installXML}

java -jar ${installerJar} ${installXML}

mv ${installXML} ${baseInstallDir}/${installDir}

echo "JBDS Installed to ${baseInstallDir}/${installDir}/"
echo ""
echo "To tweak Central URL, edit this file: "
echo ""
echo "${baseInstallDir}/${installDir}/studio/jbdevstudio.ini"
echo ""
echo "With something like:"
echo ""
echo "-Djboss.discovery.directory.url=http://localhost:8080/jbdevstudio/com.jboss.jbds.central.discovery/target/discovery-site/devstudio-directory.xml"
echo "-Djboss.discovery.site.url=http://localhost:8080/jbdevstudio/com.jboss.jbds.central.discovery/target/discovery-site/"
echo "   - or -"
echo "-Djboss.discovery.directory.url=https://devstudio.jboss.com/updates/7.0-staging/devstudio-directory.xml"
echo "-Djboss.discovery.site.url=https://devstudio.jboss.com/updates/7.0-staging/"
echo ""
echo "Then run: "
echo ""
echo "${baseInstallDir}/${installDir}/jbdevstudio -data /tmp/workspace-${installDir} &"
echo ""
