#!/bin/bash

for file in $(ls /mnt/repository/DEV/OpenData/datasource/CSU/temperature/2022/10*csv)
do
	cat $file | tail -n +2 >> 2022_all.csv
done

