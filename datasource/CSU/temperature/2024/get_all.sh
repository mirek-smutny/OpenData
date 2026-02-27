#!/bin/bash

for file in $(ls /mnt/repository/DEV/OpenData/datasource/CSU/temperature/2024/10*csv)
do
	cat $file | tail -n +2 >> 2024_all.csv
done

