#!/bin/bash
## usage = ./script.sh ~/your/path/with/files
## OR
## usage = ./script.sh ~/your/path/with/files 2>&1 | tee debug.log

target_dir="${1:-.}"
echo "[DEBUG] Processing directory: $target_dir"

[ -d "$target_dir" ] || { echo "[ERROR]: Directory '$target_dir' not found" >&2; exit 1; }
cd "$target_dir" || { echo "FAILED to enter directory" >&2; exit 1; }
echo "[DEBUG] Working in: $(pwd)"

processed=0
shopt -s extglob  # Enable extended globbing for pattern matching

# Match ANY filename ending with YYYY-MM-DD.pdf
for file in *+([^-])-????-??-??.pdf; do
    [ -e "$file" ] || { echo "[WARNING] No matching files found"; break; }

    echo "Processing: $file"
    filename="${file%.pdf}"
    
    # CORRECTED: Extract last 10 characters (YYYY-MM-DD)
    filedate="${filename: -10}"
    echo "[DEBUG] Extracted date: $filedate"

    # Validate date format strictly
    if ! date -j -f "%Y-%m-%d" "$filedate" >/dev/null 2>&1; then
        echo "[WARNING]: Invalid date format in '$file'"
        continue
    fi

    # Calculate 1st of next month
    if ! newdate=$(date -j -v1d -v+1m -f "%Y-%m-%d" "$filedate" "+%Y%m%d0000" 2>&1); then
        echo "[ERROR]: Date calculation failed: $newdate"
        continue
    fi
    
    echo "[DEBUG] New timestamp: $newdate"
    touch -t "$newdate" "$file" || { echo "[ERROR]: touch command failed"; continue; }
    
    ((processed++))
    echo "Updated to: $(date -r "$file" "+%Y-%m-%d %H:%M:%S")\n"
done

echo "Successfully processed $processed files"