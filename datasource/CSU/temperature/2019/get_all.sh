#!/bin/bash

for file in $(ls /mnt/repository/DEV/OpenData/datasource/CSU/temperature/2019/10*csv)
do
	cat $file | tail -n +2 >> 2019_all.csv
done

