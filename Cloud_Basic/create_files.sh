#!bin/bash

DIR="test_data"

# Create directory if it doesn't exist
if [ ! -d "$DIR" ]; then
  mkdir $DIR
fi

# Create files
# Generate a small file (5KB)
dd if=/dev/zero of=$DIR/small_file_5KB bs=1024 count=5
# Generate a medium/average file (5MB)
dd if=/dev/zero of=$DIR/average_file_5MB bs=1024 count=5120
# Generate a large file (1GB)
dd if=/dev/zero of=$DIR/large_file_1GB bs=1024 count=1048576

# List files
ls -lh $DIR

# Check if the files were created
if [ -f "$DIR/small_file_5KB" ] && [ -f "$DIR/average_file_5MB" ] && [ -f "$DIR/large_file_1GB" ]; then
  echo "Files created successfully!"
fi
