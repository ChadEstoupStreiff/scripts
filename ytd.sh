#!/usr/bin/env bash
# Desc: Youtube downloader
# requirements: yt-dlp, ffmpeg
# Author: Chad Estoup--Streiff 

# Check if yt-dlp exists
if ! command -v yt-dlp &> /dev/null
then
    echo "yt-dlp could not be found"
    exit
fi

# Check if ffmpeg exists
if ! command -v ffmpeg &> /dev/null
then
    echo "ffmpeg could not be found"
    exit
fi

# Check if url is set
if [ $# -eq 0 ]
then
    echo "Precise a youtube url"
    exit 1
fi


# Setup
echo "Setup ..."
ytb_url=$1
TEMP_DIR=$(mktemp -d)

# get infos
echo "Getting infos..."
ytb_info=$(yt-dlp -F $ytb_url)
ytb_video=$(
    echo "$ytb_info" | \
    grep "video only" | \
    tr -s ' ' | \
    sed 's/,//' | \
    awk '{print $1 " " $2","$14}')

ytb_audio=$(
    echo "$ytb_info" | \
    grep "audio only" | \
    tr -s ' ' | \
    sed 's/,//' | \
    awk '{print $1 " " $2","$16}')

# Make user choose
echo "Video formats:"
echo $ytb_video
selected_ytb_video=$(dialog --clear --title "Video format" --menu "Choose video format" 60 60 10 $ytb_video 3>&1 1>&2 2>&3)
echo -e "Audio formats:\n$ytb_audio"
selected_ytb_audio=$(dialog --clear --title "Audio format" --menu "Choose audio format" 60 60 10 $ytb_audio 3>&1 1>&2 2>&3)

# Download
clear
echo "Downloading video $selected_ytb_video ..."
yt-dlp -f "$selected_ytb_video" "$ytb_url" -o "$TEMP_DIR/video.%(ext)s"
echo "Downloading audio $selected_ytb_audio ..."
yt-dlp -f "$selected_ytb_audio" "$ytb_url" -o "$TEMP_DIR/audio.%(ext)s"

video_file=$(ls $TEMP_DIR | grep "video")
audio_file=$(ls $TEMP_DIR | grep "audio")
video_format="mp4"

# Merge files
echo "Merging video and audio ..."
ffmpeg -i "$TEMP_DIR/$video_file" -i "$TEMP_DIR/$audio_file" -c:v copy -c:a aac "downloaded_video.$video_format"

# Clear temp file
rm -rdf $TEMP_DIR

echo "Video downloaded !"