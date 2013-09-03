The scripts in this folder can be used to install Red Hat JBoss Developer Studio or JBoss Tools via commandline
into a new or existing Eclipse 4.2 installation.

.cmd is for Windows
.sh is for Mac or Linux

These files are simply wrappers which call Ant and run the .xml script, passing 
in variables for source, target, and what to install (if not everything). They 
contain examples of what you might want to do.

Last tested with Eclipse Standard 4.3 (Kepler) for linux 64-bit (Fedora 18, 
Oracle JDK 1.7.0_17), using:

* JBoss Developer Studio 7.0.0.GA installer jar
* JBoss Tools 4.1.0.Final update site zip

Script used is below for reference.

For a simpler script that does not require ant-contrib and can be used w/ a URL instead of only a zip as input, see director.xml. 
Note that this script will not throw helpful error messages if commandline params are invalid or missing.

-- Nick Boldt (nboldt@redhat.com), 2013-09-03

--- --- --- --- --- --- --- --- 

target=/home/nboldt/eclipse/43clean; cd ${target}; rm -fr ${target}/eclipse
tar xzf /home/nboldt/tmp/Eclipse_Bundles/eclipse-standard-kepler-R-linux-gtk-x86_64.tar.gz 
${target}/eclipse/eclipse -consolelog -nosplash -data /tmp -application org.eclipse.ant.core.antRunner -f \
  ~/tru/download.jboss.org/jbosstools/updates/scripted-installation/JBDS/installJBDS.xml \
  -DsourceZip=/home/nboldt/tmp/JBDS_Installers/jbdevstudio-product-universal-7.0.0.GA-v20130720-0044-B364.jar \
  -DtargetDir=${target}/eclipse/

# [p2.dir] Installing com.jboss.jbds.product.feature.feature.group 7.0.0.GA-v20130720-0044-B364.
# [p2.dir] Operation completed in 50795 ms.

--- --- --- --- --- --- --- --- 

target=/home/nboldt/eclipse/43clean; cd ${target}; rm -fr ${target}/eclipse
tar xzf /home/nboldt/tmp/Eclipse_Bundles/eclipse-standard-kepler-R-linux-gtk-x86_64.tar.gz 
${target}/eclipse/eclipse -consolelog -nosplash -data /tmp -application org.eclipse.ant.core.antRunner -f \
  ~/tru/download.jboss.org/jbosstools/updates/scripted-installation/installJBossTools.xml \
  -DsourceZip=/home/nboldt/tmp/JBossTools/jbosstools-Update-4.1.0.Final_2013-07-19_19-47-52-B380.zip \
  -DtargetDir=${target}/eclipse/
 
