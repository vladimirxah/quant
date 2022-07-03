#! /bin/bash
usage() {
	echo "Usage: $0 [ -t FILE | --template=FILE ] [ -r FILE | --result=FILE ]"
}
exit_abnormal() {
	usage
	exit 1
}
die() {
	echo "$*" >&2
	exit 2
}
needs_arg() {
	if [ -z "$OPTARG" ]; then
		die "No arg for --$OPT option"
	fi
}
file_exist() {
	if [ ! -r "$OPTARG" ]; then
		die "Can\`t read $OPTARG file"
	fi
}
parse_file() {
	file_template="$1"
	file_result="$2"
	BPAT="<%="
	EPAT="=%>"
	cat $file_template | while read line; do
		echo $line
		step=${#BPAT}
		for (( i=0; i<${#line}; i++ )); do
			str="${line:$i:step}"
			if [[ $str == $BPAT ]]; then
				echo "${line:($i+step)}"
			fi
			# echo "$str"
		done
	done
}
if [[ $# -eq 0 ]]; then
	echo "Invalid arguments number"
	exit_abnormal
fi
while getopts t:r:-: OPT; do
	if [ "$OPT" = "-" ]; then
		OPT="${OPTARG%%=*}"
		OPTARG="${OPTARG#$OPT}"
		OPTARG="${OPTARG#=}"
	fi
	case "$OPT" in
		t | template )	needs_arg; file_exist; TEMPLATE="$OPTARG" ;;
		r | result )	needs_arg; RESULT="$OPTARG" ;;
		??* )		die "Illegal option --$OPT" ;;
		? )		exit 2 ;;	# bad short option (error reported via getopts)
	esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list
#`touch "$RESULT"`
if [[ ! -e "$RESULT" ]]; then
	`touch "$RESULT"`
	if [ $? -ne 0 ]; then
		die "Can\`t write to result FILE"
	fi
elif [[ ! -w "$RESULT" ]]; then
	die "Can\`t write to result FILE"
fi
parse_file $TEMPLATE $RESULT
