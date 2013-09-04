#!/bin/bash

usage ()
{
  echo "Usage: $0 /path/to/jbdevstudio-product-universal-*.jar [/path/to/jre/bin/java]"
  echo ""
  echo "Usage: $0 /tmp/jbdevstudio-product-universal-7.0.0.GA-v20130720-0044-B364.jar"
  echo "Usage: $0 /tmp/jbdevstudio-product-universal-7.0.0.GA-v20130720-0044-B364.jar /usr/bin/java"
  echo ""
  exit 1;
}

if [[ $# -lt 1 ]]; then usage; fi

JREPATH=/usr/bin/java
if [[ -f $2 ]]; then JREPATH=$2; fi

# Install into user home dir, eg., /home/jsmith
baseInstallDir=${HOME}

# Want installerJar (with full path), but want only the filename (minus prefix path and trailing extension) for the dir name
installerJar=$1
installDir=${HOME}/${installerJar//.jar}
installDir=${installDir##*/}

# Set installPath
installPath=${baseInstallDir}/${installDir}
# Create installation script
installXML=/tmp/${installDir}.install.xml
echo "<?xml version='1.0' encoding='UTF-8' standalone='no'?>
<AutomatedInstallation langpack='eng'>
<com.jboss.jbds.installer.HTMLInfoPanelWithRootWarning id='introduction'/>
<com.izforge.izpack.panels.HTMLLicencePanel id='licence'/>
<com.jboss.jbds.installer.PathInputPanel id='target'>
<installpath>${installPath}</installpath>
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
<jrelocation>${JREPATH}</jrelocation>
</com.jboss.jbds.installer.CreateLinkPanel>
<com.izforge.izpack.panels.ShortcutPanel id='shortcut'/>
<com.jboss.jbds.installer.ShortcutPanelPatch id='shortcutpatch'/>
<com.izforge.izpack.panels.SimpleFinishPanel id='finish'/>
</AutomatedInstallation>" > ${installXML}

# Perform headless install
${JREPATH} -jar ${installerJar} ${installXML}

# Store script inside install folder for reuse
mv ${installXML} ${baseInstallDir}/${installDir}

echo ""
echo "JBDS Installed to ${installPath}/"
echo ""
echo "To run JBDS:"
echo ""
echo "${installPath}/jbdevstudio &"
echo ""

# echo "To tweak Central URL, edit this file: "
# echo ""
# echo "${baseInstallDir}/${installDir}/studio/jbdevstudio.ini"
# echo ""
# echo "With something like:"
# echo ""
# echo "-Djboss.discovery.directory.url=http://localhost:8080/jbdevstudio/com.jboss.jbds.central.discovery/target/discovery-site/devstudio-directory.xml"
# echo "-Djboss.discovery.site.url=http://localhost:8080/jbdevstudio/com.jboss.jbds.central.discovery/target/discovery-site/"
# echo "   - or -"
# echo "-Djboss.discovery.directory.url=https://devstudio.jboss.com/updates/7.0-staging/devstudio-directory.xml"
# echo "-Djboss.discovery.site.url=https://devstudio.jboss.com/updates/7.0-staging/"
