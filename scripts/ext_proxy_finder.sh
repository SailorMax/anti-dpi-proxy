#!/bin/bash

result_file="ext_proxies_list.txt"
source_url="https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/"

if [ -f $result_file ]; then
	echo "File $result_file already exists! Can't prepare new list."
	exit 1
fi

proxy_types=("socks5" "socks4" "http")
for proxy_type in "${proxy_types[@]}"; do
	echo "Downloading ${source_url}/${proxy_type}.txt ..."
	proxies_list=($(curl ${source_url}/${proxy_type}.txt))

	for proxy_item in "${proxies_list[@]}"; do
		echo -n "Check ${proxy_type}://${proxy_item} ... "
		curl --connect-timeout 3 --proxy ${proxy_type}://${proxy_item} https://google.com/
		if [ $? -eq 0 ]; then
			echo "good"
			echo "${proxy_type}://${proxy_item}" >> $result_file
		else
			echo "skip"
		fi
	done
done

echo "Job well done."
echo "Good proxies save in $result_file"
