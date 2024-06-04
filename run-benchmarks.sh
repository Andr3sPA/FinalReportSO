#!/bin/bash

usage="usage:\n\t$0 <device> [file_size] [repeats] [output_file]\nexample:\n\t $0 md0 512M 5 results.csv\n\n"

device=$1
file_size=${2:-64M}
record_size=16M
repeats=${3:-5}
output_file="${4:-iozone_raw_output.txt}"

if [ ! -n "$device" ]
then
        printf "you must specify the device\n$usage"
        exit
fi

if [ $repeats -gt 0 ]
then
        echo "running \"./iozone -I -R -s $file_size -r $record_size -f /mnt/$device/temp_file\" $repeats times... "
else
        exit
fi

# clear the output files
echo "run,kB,reclen,write,rewrite,read,reread,rand_read,rand_write,bkwd_read,rec_rewrite,strd_read,fwrite,frewrite,fread,freread" > $output_file

# run the test multiple times
for ((i=1; i<=repeats; i++))
do
        output=$i

        # device must be mounted
        output+=$(./iozone -I -s $file_size -r $record_size -f /mnt/$device/temp_file | grep -x " *[0-9].*")
        sed -e "s/ \+/,/g" <(echo $output) >> $output_file
done

echo "All benchmarks completed. Results saved in $output_file."
