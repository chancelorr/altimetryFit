#! /usr/bin/env bash

# building off get_pgc_fullres.sh by ben
# by chance

# Arguments

# PGC s3 url
url=$(echo "$1" | sed 's|https://[^/]*/stac-browser/#/external/|https://|g')

# where to put the filtered file
output_dir=$2

# filter aguments file (empty means just download the data)
# in default_args folder
filter_arg_file=$3

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

echo -e "\nrunning dem_filter.py\n"
[ -f $filter_arg_file ] && dem_filter.py $dem_file $filt_file @$filter_arg_file && exit

[ -f default_args.txt ] && dem_filter.py $dem_file $filt_file @default_args.txt

#[ -f $filt_file ] && $(rm $dem_file $match_file $mask_file)

