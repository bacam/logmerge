#!/bin/bash

# *Very* simple test using a single logfile

set -ex

DIR=`mktemp -d`

echo Feb 24 08:30:07 line 1 > "$DIR/log"
echo Feb 24 08:30:08 line 2 >> "$DIR/log"

./logmerge-mkoffsets "$DIR/log" > "$DIR/offsets"

echo Should output two lines:

./logmerge --offsets "$DIR/offsets"

echo

echo Feb 24 08:30:09 line 3 >> "$DIR/log"
mv "$DIR/log" "$DIR/log.0"

echo Feb 24 08:30:10 line 4 > "$DIR/log"

echo Should output lines 3 and 4:

./logmerge --offsets "$DIR/offsets"

# Newer stuff moves to files ending .1, .2, etc without .0

rm "$DIR/log.0"

echo Feb 24 08:30:11 line 5 >> "$DIR/log"
mv "$DIR/log" "$DIR/log.1"

echo Feb 24 08:30:12 line 6 > "$DIR/log"

echo Should output lines 5 and 6:

./logmerge --offsets "$DIR/offsets"

echo Feb 24 08:30:09 line 7 >> "$DIR/log"
mv "$DIR/log" "$DIR/log.0"
chmod a-r "$DIR/log.0"

echo Feb 24 08:30:10 line 8 > "$DIR/log"

echo Should output line 8, complain about no read permissions and keep going:

./logmerge --offsets "$DIR/offsets"

rm -r "$DIR"
