#!/bin/bash

for file in $(ls /mnt/repository/DEV/OpenData/datasource/CSU/temperature/2025/10*csv)
do
	cat $file | tail -n +2 >> 2025_all.csv
done

