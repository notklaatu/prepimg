#!/usr/bin/env bash

## "prepimg.sh"
## written by Alan Formy-Duval
## August 10, 2021

## prepares screenshot images for inclusion in opensource.com articles
## checks the width and reduces as needed
## adds a border
## filenames are prepended with Ready after processing

## Screenshots should be created using GNOME extension - Screenshot Tool
## Reference: https://extensions.gnome.org/extension/1112/screenshot-tool/
## configured to save screenshots to the directory shown below:
SCREENSHOTS=${SCREENSHOTS:-"$HOME/Pictures/Screenshots"}
READY=${READY:-"$SCREENSHOTS/Ready"}
BORDER=${BORDER:-black}
VERBOSE=0

## opensource.com requires a maximum width of 600 for images
## minus 2 for adding a border
MAXWIDTH=598

## exit on most errors
set -e

create_dir() {
    mkdir -p "${SCREENSHOTS}" || true
}

process_img() {
    # verify that file is an image file, and then get dimensions
    if file "${SCREENSHOTS}"/"${1}" | grep -qE 'image|bitmap'; then
	[[ $VERBOSE -gt 0 ]] && echo "${1} is an image"
	W=$(identify -format %w "${SCREENSHOTS}"/"${1}")
    else
	echo "File ${SCREENSHOTS}/${1} is not an image."
	W=0
    fi

    # resize and border
    if [ "$W" -gt "$MAXWIDTH" ]
    then
	[[ $VERBOSE -gt 0 ]] && echo "${1} is ${W} - reducing"
	convert -resize "${MAXWIDTH}" \
		-bordercolor $BORDER \
		-border 1 \
		"${SCREENSHOTS}"/"${1}" \
		"${READY}"/"${1}"
    else
	convert -bordercolor $BORDER \
		-border 1 \
		"${SCREENSHOTS}"/"${1}" \
		"${READY}"/"${1}"
    fi
}

## parse opts
while [ True ]; do
if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo " "
    echo "$0 [OPTIONS]"
    echo "--verbose, -v     Be verbose"
    echo "--directory, -d   Screenshot directory (default: $SCREENSHOTS)"
    echo "--border, -b      Border color (default: black)"
    echo " "
    exit
elif [ "$1" = "--verbose" -o "$1" = "-v" ]; then
    VERBOSE=1
    shift 1
elif [ "$1" = "--directory" -o "$1" = "-d" ]; then
    SCREENSHOTS="${2}"
    shift 2
elif [ "$1" = "--border" -o "$1" = "-b" ]; then
    BORDER="${2}"
    shift 2
else
    break
fi
done

# main
create_dir

if [ -z "$(ls -A ${SCREENSHOTS})" ]
then
    echo "No images found."
    exit
else
    mkdir -p "${READY}" || true
fi

for i in "${SCREENSHOTS}"/*.???; do
    process_img "`basename "${i}"`"
done
