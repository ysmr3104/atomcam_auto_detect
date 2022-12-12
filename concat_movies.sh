#!/bin/sh
file_detected_mov="_detected.mp4"
file_detect_list="detected.txt"
rm -rf ${file_detected_mov} ${file_detect_list}
find -s . -type f -name "*.mp4" | perl -pe 's/^\.\//file /g' > detected.txt
ffmpeg -y -f concat  -i detected.txt -c copy tmp${file_detected_mov}
ffmpeg -y -i tmp${file_detected_mov} -f mp4 -vcodec libx264 ${file_detected_mov}
rm -rf tmp${file_detected_mov}
