import os 
dir_path = os.path.dirname(os.path.realpath(__file__))
from optparse import OptionParser
import re
from os import remove
from shutil import move

usage = "\n\n\
Usage 1: %prog -O </path/to/outputFile>\n\n\
This script will regenerate fragment.properties files for stable, development, staging, and snapshots properties,\n\
then merge those into a single ide-config.properties file."

parser = OptionParser(usage)

parser.add_option("-O", "--outputFile", dest="outputFile", help="merged destination file with full path")
parser.add_option("-C", "--snapshotsRegex",   dest="snapshotsRegex", help="regex to apply to current-snapshots (ci) file")
parser.add_option("-S", "--stagingRegex",     dest="stagingRegex", help="regex to apply to current-staging file")
parser.add_option("-D", "--developmentRegex", dest="developmentRegex", help="regex to apply to current-development file")
parser.add_option("-R", "--stableRegex",      dest="stableRegex", help="regex to apply to current-stable (release) file")
parser.add_option("-X", "--debug",      dest="debug", action="store_true", help="if set, provide more console debug output")

(options, args) = parser.parse_args()

if not options.outputFile:
    parser.error("Must to specify -O /path/to/outputFile")

outputFile = options.outputFile

filenames = ['ide-config.current-snapshots-fragment.properties', 'ide-config.current-staging-fragment.properties', \
    'ide-config.current-development-fragment.properties', 'ide-config.current-stable-fragment.properties', \
    'ide-config.other-fragment.properties']

buildTypes_d = {'snapshots': options.snapshotsRegex, 'staging': options.stagingRegex, 'development': options.developmentRegex, 'stable': options.stableRegex} 

# store key/value pairs like jboss.discovery.earlyaccess.site.url|devstudio|10.2.0.GA = https://devstudio.redhat.com/10.0/staging/updates/discovery.earlyaccess/10.2.0.GA/
fulllines_d = {}
productversions_d = {}

# split line and store in fulllines_d and productversions_d
# also check for dupes and fail if any found
# also check that if stableRegex is defined, all snapshot, staging, or development URLs with GA or Final are commented out
def storeLines(lineFixed, line, fname):
    pair = lineFixed.split("=")
    if len(pair) > 1 and (pair[0].count("|jbosstools|") > 0 or pair[0].count("|devstudio|") > 0):
        # check for duplicate keys and fail the build if any found
        if not pair[0] in fulllines_d:
            fulllines_d[pair[0]] = pair[1].rstrip()
        elif pair[0][:1] == "#": # comment block
            print "[WARNING] Commented key " + pair[0] + " already defined"
        else:
            if lineFixed != line:
                pairBefore = line.split("=")
                print "[ERROR] Transformed key " + pair[0] + " (was: " + pairBefore[0] + ") already defined as:"
            else:
                print "[ERROR] Unchanged key " + pair[0] + " already defined as:"
            print "[ERROR] " + fulllines_d[pair[0]]
            print "[ERROR] Duplicate key found reading file:"
            exit(str(fname))

        triple = pair[0].split("|") # jboss.discovery.earlyaccess.list.url|devstudio|10.3.0.AM1

        # check that if stableRegex is defined, all snapshot, staging, or development URLs with GA or Final are commented out
        if options.stableRegex and not pair[0].startswith("#") and (triple[2].count(".Final") or triple[2].count(".GA")):
            print "[ERROR] Need to comment out lines with " + triple[1] + "|" + triple[2] + " from file:"
            exit(str(fname))

        # store version = jbosstools|jboss.discovery.directory.url and version = devstudio|jboss.central.webpage.url key pairs; dupes are OK here
        if len(triple) > 1 and (triple[0].startswith("jboss.discovery") or triple[0].startswith("jboss.central")): # store only the central/discovery keys
            if not triple[2] in productversions_d:
                productversions_d[triple[2]] = { triple[0]: triple[1] } # 10.3.0.AM1 => { jboss.discovery.earlyaccess.list.url : devstudio }
            else:
                productversions_d[triple[2]][triple[0]] = triple[1]
            if options.debug:
                print "[DEBUG] Store: productversions_d[ " + triple[2] + " ] = { " + triple[0] + ": " + triple[1] + " }"

# merge regex changes into .merged files
for fname in filenames:
    with open(dir_path + os.sep + fname) as infile:
        outfile = open(dir_path + os.sep + fname + '.merged', 'w')
        if options.debug:
            print "[DEBUG] Reading properties from: " + fname
        for line in infile:
            linePrinted = 0 # have we printed the file?
            fileType=re.sub('ide-config.current-(.+)-fragment.properties', r"\1", fname) # snapshots
            for fileTypeString, regexGroups in buildTypes_d.items():
                if fileType == fileTypeString and regexGroups: # if we're doing the snapshots file and there's a snapshots regex defined
                    regexpairs = regexGroups.split(";") # 4.4.2.Final,4.4.3.AM1 and 10.2.0.GA,10.3.0.AM1
                    lineFixed = line
                    for regexpair in regexpairs:
                        regex = regexpair.split(",") # 4.4.2.Final -> 4.4.3.AM1
                        lineFixed = re.sub(regex[0], regex[1], lineFixed)
                    storeLines(lineFixed, line, infile)
                    outfile.write(lineFixed)
                    linePrinted = 1
            if linePrinted == 0:
                storeLines(line, line, infile)
                outfile.write(line)
        outfile.close()
    infile.close()

# run tests before merging changes into ide-config.properties and the fragment files
# if options.debug:
#     count=0
#     for key, value in fulllines_d.items():
#         count +=1
#         print "[DEBUG] ["+str(count).zfill(3)+"] " + key + " => " + value

# for each group of keys (for a given prod|version) check for correct # of keys - should be 8 keys or more
countBlock = 0
for version in sorted(productversions_d.iterkeys()):
    countBlock += 1
    countInner = 0
    if len(productversions_d[version]) != 8:
        errMsg = "[ERROR] Expected 8 keys for jboss.*|*|" + version + ", but got: " + str(len(productversions_d[version])) + \
            " - check your src/main/ide.config.*-fragment.properties files"
        print errMsg
        for key in sorted(productversions_d[version].iterkeys()):
            countInner += 1
            if options.debug:
                print "[DEBUG] [" + str(countBlock).zfill(2) + ", " + str(countInner).zfill(2) + "] " + version + " => " + \
                    key + " => " + productversions_d[version][key]
        if options.debug:
            print ""
        exit (errMsg)

# Finally, if everything went well above, write changes to output file, ide-config.properties
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
