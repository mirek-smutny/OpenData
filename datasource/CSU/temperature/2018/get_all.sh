#!/bin/bash

for file in $(ls /mnt/repository/DEV/OpenData/datasource/CSU/temperature/2018/10*csv)
do
	cat $file | tail -n +2 >> 2018_all.csv
done

