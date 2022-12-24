#!/bin/sh
file_lighten="_lighten.jpg"
rm -rf ${file_lighten}
target_files=`find -s . -type f -name "*.jpg" | perl -pe 's/\n/ /g'`
first_file=`echo ${target_files} | awk -F " " '{print $1}'`
cp -p ${first_file} ${file_lighten}
for target_file in ${target_files}
do
    convert ${file_lighten} ${target_file} -gravity center -compose lighten -composite ${file_lighten}
done
