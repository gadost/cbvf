#!/bin/bash
##### Author: maxn / nikolaev.makc@gmail.com
set +e
set -o pipefail

#change path for videofiles folder
video_path="/home/videos"

#find all files in specified path
find $video_path -type f > full_files_list.tmp

y=$(wc -l full_files_list.tmp)

let g=1

while read file
do
	#use ffprobe via docker. Also you can use ffprobe -v error -count_frames -threads 0 -i $file 2>&1
	bfile=$(docker run --sig-proxy=true --rm -v $video_path:$video_path sjourdan/ffprobe -v error -count_frames -threads 0 -i $file 2>&1)
	x=$(echo $bfile| grep -cE "(partial|no frame)")
	if [ "$x" -eq 1 ]; then
		echo $file >> broken.tmp
                echo "found partial file ${file}"
	else
		echo "files $g / $y tested"
	fi
	let g=g+1
done < full_files_list.tmp
