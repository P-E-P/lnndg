#!/bin/bash

# Build a dataset for neural network training from font file
 
# * This file is part of LNNDG (https://github.com/P-E-P/lnndg).
# * Copyright (c) 2019 Patry Pierre-Emmanuel.
# * 
# * This program is free software: you can redistribute it and/or modify  
# * it under the terms of the GNU General Public License as published by  
# * the Free Software Foundation, version 3.
# *
# * This program is distributed in the hope that it will be useful, but 
# * WITHOUT ANY WARRANTY; without even the implied warranty of 
# * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# * General Public License for more details.
# *
# * You should have received a copy of the GNU General Public License 
# * along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# Default path
EXPORT_PATH="output"

# Force overwrite
FORCE_OW=false

# Input
INPUT_PATH=""

# Image size
IMAGE_WIDTH=28
IMAGE_HEIGHT=28

# Horizontal minimum and maximum offset
WIDTH_LW_OFFSET=-5
WIDTH_HG_OFFSET=+4

# Vertical minimum and maximum offset
HEIGHT_LW_OFFSET=-2
HEIGHT_HG_OFFSET=3


# $1 is font file
function from_font_file () {

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
                    "$EXPORT_PATH"/"$char"_"$filename"_$i$j.bmp > /dev/null 2>&1
                done
            done
        done
    else
        echo "$1 is not a valid font file"
        return -1
    fi
}


# Parsing arguments

while (( "$#" )); do
    case "$1" in
        -f|--force)
            FORCE_OW=true
            #echo "Forcing"
            shift
            ;;
        -w|--width)
            IMAGE_WIDTH=$2
            #echo "Width: $2"
            shift 2
            ;;
        -h|--height)
            IMAGE_HEIGHT=$2
            #echo "Height: $2"
            shift 2
            ;;
        -i|--input)
            INPUT_PATH=$2
            #echo "Input: $2"
            shift 2
            ;;
        -o|--output)
            EXPORT_PATH=$2
            #echo "Export path: $2"
            shift 2
            ;;
        --) # end argument parsing
            shift
            break
            ;;
        -*|--*=) # unsupported flags
            echo "Error: Unsupported flag $1" >&2
            exit 1
            ;;
        *) # preserve positional arguments
            PARAMS="$PARAMS $1"
            shift
            ;;
    esac
done

# Preventing lowest offset from being greater than the highest one
if [ $WIDTH_LW_OFFSET -gt $WIDTH_HG_OFFSET ]; then
    echo "Reverting offset order"
    TMP=$WIDTH_LW_OFFSET
    WIDTH_LW_OFFSET=$WIDTH_HG_OFFSET
    WIDTH_HG_OFFSET=$TMP
fi


if [ $HEIGHT_LW_OFFSET -gt $HEIGHT_HG_OFFSET ]; then
    echo "Reverting offset order"
    TMP=$HEIGHT_LW_OFFSET
    HEIGHT_LW_OFFSET=$HEIGHT_HG_OFFSET
    HEIGHT_HG_OFFSET=$TMP
fi



IMAGE_SIZE="$IMAGE_WIDTH"x"$IMAGE_HEIGHT"


# Checking if export path exist and ask confirmation from the user

if [[ -d $EXPORT_PATH ]]; then
    if [ "$FORCE_OW" = false ] ; then
    
        read -p "File already exist, do you want to overwrite (y/n)?" choice
        case "$choice" in
            y|Y ) 
                echo "Overwriting."
                ;;
            * )
                echo "Aborting."
                exit -1
                ;;
        esac
    fi
else
    mkdir $EXPORT_PATH
fi

if [ "$INPUT_PATH" == "" ]; then
    # Scan system for font file
    echo "Scanning filesystem"
else
    from_font_file "$INPUT_PATH"
fi


