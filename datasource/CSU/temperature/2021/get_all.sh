#!/bin/bash

for file in $(ls /mnt/repository/DEV/OpenData/datasource/CSU/temperature/2021/10*csv)
do
	cat $file | tail -n +2 >> 2021_all.csv
done

