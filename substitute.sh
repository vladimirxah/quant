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
parse_line() {
	line="$1"
	line_for=$line
	PAT="$2"
	step=${#BPAT}
	declare -A pairs
	for (( i=0; i<${#line_for}; i++ )); do
		str="${line_for:$i:step}"
		if [[ $str == $BPAT ]]; then
			VAR="${line_for:($i+step)}"
			while [[ $VAR =~ $EPAT.* ]]; do
				VAR=${VAR%%=%>*}
			done
			if [[ ! $VAR =~ $BPAT ]]; then
				#echo "RESULT - $VAR"
				eval "ENVVAR=\"\$$VAR\""
				#echo "RESULTE- $ENVVAR"
				line=${line/$BPAT$VAR$EPAT/"$ENVVAR"}
				#pairs["$VAR"]="$ENVVAR"
			fi
		fi
	done
#if [[ ${#pairs[@]} -eq 0 ]]; then
#	echo $line
#	return
#fi
#for key in "${!pairs[@]}"; do
#	echo "\tRESULT - $key"
#	echo "\tRESULTE- ${pairs[$key]}"
#	line=${line/$BPAT$key$EPAT/"${pairs[$key]}"}
#done
	echo $line
}
parse_file() {
	file_template="$1"
	file_result="$2"
	cat $file_template | while read -r line; do
		echo $(parse_line "$line" $BPAT) # >> $file_result
	done
}
BPAT="<%="
EPAT="=%>"
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
if [[ ! -e "$RESULT" && $RESULT != "" ]]; then
	`touch "$RESULT"`
	if [ $? -ne 0 ]; then
		die "Can\`t write to result FILE"
	fi
elif [[ ! -w "$RESULT" && $RESULT != "" ]]; then
	die "Can\`t write to result FILE"
elif [[ $RESULT != "" ]]; then
	echo "" > $RESULT
	parse_file $TEMPLATE >> $RESULT
fi
