#!/bin/sh
rm -rf _detected.mp4 detected.txt
find -s . -type f -name "*.mp4" | perl -pe 's/^\.\//file /g' > detected.txt
ffmpeg -y -f concat  -i detected.txt -c copy tmp_detected.mp4
ffmpeg -y -i tmp_detected.mp4 -f mp4 -vcodec libx264 _detected.mp4
rm -rf tmp_detected.mp4
