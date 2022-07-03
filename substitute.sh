#! /bin/bash

if [[ $# -ne 2 ]]; then
	echo "Invalid arguments number"
	exit 1
fi
if [[ ! -r $1 ]]; then
	echo "Can\`t find file to parse"
	exit 1
fi
if [[ ! -w $2 ]]; then
	echo "Can\`t write to target file"
	exit 1
fi
