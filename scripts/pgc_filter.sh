#! /usr/bin/env bash

# Script: pgc_filter.sh
# Author: Derived from get_pgc_fullres.sh by Ben, modified by Chance
#
# Description:
# This script downloads high-resolution DEM (Digital Elevation Model) data from 
# the Polar Geospatial Center (PGC) using a provided S3 URL. The script retrieves 
# the DEM file, matchtag file, and bitmask file, storing them in the specified 
# output directory. It includes an optional filtering step using `dem_filter.py`, 
# which applies predefined filtering arguments.
#
# Positional Arguments:
#  1. url (string)        - PGC S3 URL of the dataset. This should be the link to 
#                           the JSON metadata file. Script will convert sed substitute 
#                           the corresponding DEM, matchtag, and bitmask file URLs.
#  2. output_dir (string) - Directory where the downloaded files will be stored.
#                           Must exist before running the script.
#  3. filter_arg_file (string, optional) - Path to a text file containing filtering 
#                           parameters for `dem_filter.py`. If left empty, the script 
#                           will skip the filtering step.
#
# Outputs:
#  - Downloads the following files into the specified output directory:
#    * DEM file (`*_dem.tif`)
#    * Matchtag file (`*_matchtag.tif`)
#    * Bitmask file (`*_bitmask.tif`)
#  - If filtering is enabled, generates:
#    * Filtered DEM file (`*_dem_filt.tif`)
#  - Skips downloading files that already exist in the output directory.
#
# Notes:
# - The script currently exits before running the filtering step.
# - Ensure `wget` is installed to fetch remote files.
# - If `dem_filter.py` is used, make sure it is accessible in the system's PATH.
#
# Example Usage:
# ./get_pgc_data.sh "https://pgc-url/stac-browser/#/external/some_dem.json" "/path/to/output" "filter_args.txt"

# Function to display usage information
usage() {
  echo "Usage: $0 <url> <output_dir> [<filter_arg_file>] [-w] [-d] [-h]"
  echo " "
  echo "Arguments:"
  echo "  url              PGC STAC URL of the dataset (link to the JSON metadata file)."
  echo "  output_dir       Directory where downloaded files will be stored."
  echo "  filter_arg_file  (Optional) Path to a file with filtering parameters for dem_filter.py."
  echo " "
  echo "Options:"
  echo "  -w  Overwrite existing files (forces re-downloading)."
  echo "  -d  Download files only, then exit (skip filtering)."
  echo "  -h  Display this help message."
  echo " "
  echo "Example:"
  echo "  $0 \"https://pgc-url/stac-browser/#/external/some_dem.json\" \"/path/to/output\" \"filter_args.txt\" -w"
  echo " "
  exit 1
}

# Arguments

# PGC s3 url
url=$(echo "$1" | sed 's|https://[^/]*/stac-browser/#/external/|https://|g')

# where to put the filtered file
output_dir=$2

# filter aguments file (empty means just download the data)
# in default_args folder
filter_arg_file=$3

# Initialize variables
overwrite="" # overwrite option for dem_filter.py. Capitalized bc it is a python boolean
download_only=false # skip dem_filter

# Parse options using getopts
while getopts "wdh" opt; do
  case "$opt" in
    w) overwrite="--overwrite";;
    d) download_only=true;;
    h) usage;;
    *) usage;;
  esac
done

dem_url=$(sed 's/.json/_dem.tif/' <<< "$url")
match_url=$(sed 's/.json/_matchtag.tif/' <<< "$url")
mask_url=$(sed 's/.json/_bitmask.tif/' <<< "$url")
dem_file=$(basename "$dem_url")
filt_file=$(sed -e 's/_2m_/_32m_/' -e 's/_dem.tif/_dem_filt.tif/' <<< "$dem_file")

#echo "dem_url="$dem_url
#echo "dem_file="$dem_file
#echo "filt_file="$filt_file

match_file=$(basename $match_url)
mask_file=$(basename $mask_url)

for url in $dem_url $match_url $mask_url; do
    file=$(basename $url)
    #echo "checking for "$output_dir"/"$file""
    [ -f "$output_dir"/"$file" ] || echo "downloading $file"
    [ -f "$output_dir"/"$file" ] || wget -q --show-progress -P $output_dir $url
done

#wget -q $dem_url && wget -q $match_url && wget -q $mask_url || $(echo "COULD NOT DOWNLOAD"; exit 1)

if [[ "$download_only" == "true" ]]; then
    echo -e "exiting without running filter function"
    exit
fi

############# Filter DEM with dem_filter.py
echo -e "\nrunning dem_filter.py\n"

# if filter_arg_file is specified, input to dem_filter
echo "dem_filter.py $output_dir/$dem_file $output_dir/$filt_file @$filter_arg_file"
[ -f $filter_arg_file ] && dem_filter.py $output_dir/$dem_file $output_dir/$filt_file @$filter_arg_file $overwrite && exit

# if not, run with default args
echo "dem_filter.py $output_dir/$dem_file $output_dir/$filt_file @default_args.txt"
[ -f default_args.txt ] && dem_filter.py $dem_file $filt_file @default_args.txt $overwrite

# Optionally remove original downloaded data
#[ -f $filt_file ] && $(rm $dem_file $match_file $mask_file)


