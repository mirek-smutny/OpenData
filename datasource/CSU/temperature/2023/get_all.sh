#!/bin/bash

for file in $(ls /mnt/repository/DEV/OpenData/datasource/CSU/temperature/2023/10*csv)
do
	cat $file | tail -n +2 >> 2023_all.csv
done

