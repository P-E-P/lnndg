#!/bin/bash

# Build a dataset for neural network training from font file


# Image size
IMAGE_WIDTH=28
IMAGE_HEIGHT=28

# Horizontal minimum and maximum offset
WIDTH_LW_OFFSET=-5
WIDTH_HG_OFFSET=+4

# Vertical minimum and maximum offset
HEIGHT_LW_OFFSET=-2
HEIGHT_HG_OFFSET=3


IMAGE_SIZE="$IMAGE_WIDTH"x"$IMAGE_HEIGHT"

# Preventing lowest offset from being greater than the highest one
if [ $LW_OFFSET -gt $HG_OFFSET ]; then
    TMP=$LW_OFFSET
    $LW_OFFSET=$HG_OFFSET
    $HG_OFFSET=$TMP
fi

# Checking arguments
if [ "$#" -ne 1 ]; then
    echo "Incorrect usage:"
    echo "$0 path/to/font_file"
    exit -1
fi


if [[ -f $1 ]]; then
    
    echo "$1 is a file"

    filename=$(basename -- "$1")
    extension="${filename##*.}"
    filename="${filename%.*}"

    echo "Filename: $filename"
    echo "Extension: $extension"
    
    for char in {a..z} ; do # Change charset for more letters
        
        #echo "$char"
        
        for i in $(seq $WIDTH_LW_OFFSET $WIDTH_HG_OFFSET) ; do
            for j in $(seq $HEIGHT_LW_OFFSET $HEIGHT_HG_OFFSET) ; do

                if [[ ${i:0:1} != "-" ]] && [[ ${i:0:1} != "+" ]] ; then
                    i="+${i}"
                fi

                if [[ ${j:0:1} != "-" ]] && [[ ${j:0:1} != "+" ]] ; then
                    j="+${j}"
                fi

                #echo $i$j
                
                # Creating the bitmap using image magic
                convert -resize $IMAGE_SIZE -extent $IMAGE_SIZE -gravity center \
                -channel RGB -threshold 50\% -pointsize 72 -font "$1" label:"$char" \
                \( -clone 0 -repage $IMAGE_SIZE$i$j \) -delete 0 -flatten\
                res/"$char"_"$filename"_$i$j.bmp > /dev/null 2>&1
            done
        done
    done
else
    echo "$1 is not a valid font file"
    exit -1
fi


