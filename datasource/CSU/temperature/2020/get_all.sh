#!/bin/bash

for file in $(ls /mnt/repository/DEV/OpenData/datasource/CSU/temperature/2020/10*csv)
do
	cat $file | tail -n +2 >> 2020_all.csv
done

