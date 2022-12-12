#!/bin/sh
rm -rf _lighten.jpg
target_files=`find -s . -type f -name "*.jpg" | perl -pe 's/\n/ /g'`
convert -colorspace rgb -size 1920x1080 xc:black _lighten.jpg
for target_file in ${target_files}
do
    convert _lighten.jpg ${target_file} -gravity center -compose lighten -composite _lighten.jpg
done
