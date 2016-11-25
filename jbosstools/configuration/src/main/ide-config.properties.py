import os 
dir_path = os.path.dirname(os.path.realpath(__file__))
from optparse import OptionParser
import re

usage = "\n\n\
Usage 1: %prog -i <version_jbt> -d <version_ds> -t <buildType> -O </path/to/outputFile>\n\n\
This script will regenerate fragment.properties files for stable, development, staging, and snapshots properties,\n\
then merge those into a single ide-config.properties file."

parser = OptionParser(usage)
parser.add_option("-i", "--version_jbt",dest="version_jbt", help="JBIDE Fix Version, eg., 4.4.2.Final")
parser.add_option("-d", "--version_ds", dest="version_ds", help="JBDS Fix Version, eg., 10.2.0.GA")
parser.add_option("-t", "--buildType",  dest="buildType", help="buildType should be one of staging, development, stable")
parser.add_option("-O", "--outputFile", dest="outputFile", help="merged destination file with full path")

parser.add_option("-C", "--snapshotsRegex",   dest="snapshotsRegex", help="regex to apply to current-snapshots (ci) file")
parser.add_option("-S", "--stagingRegex",     dest="stagingRegex", help="regex to apply to current-staging file")
parser.add_option("-D", "--developmentRegex", dest="developmentRegex", help="regex to apply to current-development file")
parser.add_option("-R", "--stableRegex",      dest="stableRegex", help="regex to apply to current-stable (release) file")

(options, args) = parser.parse_args()

if not options.version_jbt or not options.version_ds or not options.buildType or not options.outputFile:
    parser.error("Must to specify ALL commandline flags")

jbide_fixversion = options.version_jbt
jbds_fixversion = options.version_ds
buildType = options.buildType
outputFile = options.outputFile

def printme( str ):
   "This prints a passed string into this function"
   print str
   return

filenames = ['ide-config.current-snapshots-fragment.properties', 'ide-config.current-staging-fragment.properties', \
    'ide-config.current-development-fragment.properties', 'ide-config.current-stable-fragment.properties', \
    'ide-config.other-fragment.properties']

d = {'snapshots': options.snapshotsRegex, 'staging': options.stagingRegex, 'development': options.developmentRegex, 'stable': options.stableRegex} 

with open(outputFile, 'w') as outfile:
    for fname in filenames:
        with open(dir_path + os.sep + fname) as infile:
            for line in infile:
                linePrinted = 0 # have we printed the file?
                fileType=re.sub('ide-config.current-(.+)-fragment.properties', r"\1", fname) # snapshots
                for fileTypeString, regexGroups in d.items():
                    if fileType == fileTypeString and regexGroups: # if we're doing the snapshots file and there's a snapshots regex defined
                        regexpairs = regexGroups.split(";") # 4.4.2.Final,4.4.3.AM1 and 10.2.0.GA,10.3.0.AM1
                        lineFixed = line
                        for regexpair in regexpairs:
                            regex = regexpair.split(",") # 4.4.2.Final -> 4.4.3.AM1
                            lineFixed = re.sub(regex[0], regex[1], lineFixed)
                        outfile.write(lineFixed)
                        linePrinted = 1
                if linePrinted == 0:
                    outfile.write(line)

