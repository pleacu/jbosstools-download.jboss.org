import os 
dir_path = os.path.dirname(os.path.realpath(__file__))
from optparse import OptionParser
import re
from os import remove
from shutil import move

usage = "\n\n\
Usage 1: %prog -i <version_jbt> -d <version_ds> -t <buildType> -O </path/to/outputFile>\n\n\
This script will regenerate fragment.properties files for stable, development, staging, and snapshots properties,\n\
then merge those into a single ide-config.properties file."

parser = OptionParser(usage)

parser.add_option("-O", "--outputFile", dest="outputFile", help="merged destination file with full path")
parser.add_option("-C", "--snapshotsRegex",   dest="snapshotsRegex", help="regex to apply to current-snapshots (ci) file")
parser.add_option("-S", "--stagingRegex",     dest="stagingRegex", help="regex to apply to current-staging file")
parser.add_option("-D", "--developmentRegex", dest="developmentRegex", help="regex to apply to current-development file")
parser.add_option("-R", "--stableRegex",      dest="stableRegex", help="regex to apply to current-stable (release) file")

(options, args) = parser.parse_args()

if not options.outputFile:
    parser.error("Must to specify -O /patht/to/outputfile")

outputFile = options.outputFile

filenames = ['ide-config.current-snapshots-fragment.properties', 'ide-config.current-staging-fragment.properties', \
    'ide-config.current-development-fragment.properties', 'ide-config.current-stable-fragment.properties', \
    'ide-config.other-fragment.properties']

d = {'snapshots': options.snapshotsRegex, 'staging': options.stagingRegex, 'development': options.developmentRegex, 'stable': options.stableRegex} 

# merge regex changes into .merged files
for fname in filenames:
    with open(dir_path + os.sep + fname) as infile:
        outfile = open(dir_path + os.sep + fname + '.merged', 'w')
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
        outfile.close()
    infile.close()

with open(outputFile, 'w') as outfile:
    for fname in filenames:
        # rename the .merged files to overwrite their original file
        if os.path.exists(dir_path + os.sep + fname + '.merged'):
            remove(dir_path + os.sep + fname)
            move(dir_path + os.sep + fname + '.merged', dir_path + os.sep + fname)
        # merge fragments into ide-config.properties
        with open(dir_path + os.sep + fname) as infile:
            for line in infile:
                outfile.write(line)
        infile.close()
outfile.close()

