#!/bin/sh
file_lighten="_lighten.jpg"
rm -rf ${file_lighten}
target_files=`find -s . -type f -name "*.jpg" | perl -pe 's/\n/ /g'`
convert -colorspace rgb -size 1920x1080 xc:black ${file_lighten}
for target_file in ${target_files}
do
    convert ${file_lighten} ${target_file} -gravity center -compose lighten -composite ${file_lighten}
done
