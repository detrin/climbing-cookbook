#!/bin/bash

set -e 
# Ensure ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it to proceed."
    exit 1
fi

if ! command -v exiftool &> /dev/null; then
    echo "ExifTool is not installed. Please install it to proceed."
    exit 1
fi

# Specify the image directory
IMAGE_DIR="./src/assets"
FIXED_IMAGE_DIR="./src/assets/fixed"
RAW_IMAGE_DIR="./src/assets/raw"

# Create directories for processed images
mkdir -p "$FIXED_IMAGE_DIR"
mkdir -p "$RAW_IMAGE_DIR"

# Limit for the dimensions
LIMIT=1526
IMAGE_LIST=$(find "$IMAGE_DIR" -type f -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" -o -name "*.svg")
METADATA_TEXT="This is part of Climbing Cookbook"

for image in $IMAGE_LIST
do
    if [ ! -f "$image" ]; then
        continue
    fi
 
    # Get current dimensions
    dimensions=$(identify -format "%wx%h" "$image")
    width=$(echo "$dimensions" | cut -d'x' -f1)
    height=$(echo "$dimensions" | cut -d'x' -f2)

    # Determine if resizing is necessary
    if [ "$width" -gt "$LIMIT" ] || [ "$height" -gt "$LIMIT" ]; then
        echo "Resizing $image with dimensions $dimensions..."

        # Determine scaling factor based on larger dimension
        if [ "$width" -gt "$height" ]; then
            # Resize based on width
            scale="$LIMIT"
            magick "$image" -resize "${scale}x" "$FIXED_IMAGE_DIR/$(basename "${image%.*}").png"
        else
            # Resize based on height
            scale="$LIMIT"
            magick "$image" -resize "x${scale}" "$FIXED_IMAGE_DIR/$(basename "${image%.*}").png"
        fi
    else
        echo "Copying $image without resizing..."
        magick "$image" "$FIXED_IMAGE_DIR/$(basename "${image%.*}").png"
    fi
    exiftool -overwrite_original -Comment="$METADATA_TEXT" "$FIXED_IMAGE_DIR/$(basename "${image%.*}").png"
done

echo "All images processed. Replacing original images."

set +e
mv "$IMAGE_DIR"/*.{jpg,jpeg,png,webp,gif,svg} "$RAW_IMAGE_DIR" 2>/dev/null
set -e

echo "Moving processed images to the image directory."
for image in "$FIXED_IMAGE_DIR"/*.png
do
    mv "$image" "$IMAGE_DIR"
done

rm -rf "$FIXED_IMAGE_DIR"
rm -rf "$RAW_IMAGE_DIR"

echo "Process complete."