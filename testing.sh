#!/bin/bash

package_dir="$1"
target_dir="$HOME"

if [[ ! -d "$package_dir" ]]; then
  echo "Package directory '$package_dir' does not exist."
  exit 1
fi

package_dir=$(realpath "$package_dir")

# Find all files inside the package
files=$(find "$package_dir" -type f)

for file in $files; do
  rel_path=$(realpath --relative-to="$package_dir" "$file")
  target_path="$target_dir/$rel_path"
  echo "$target_path"
done
