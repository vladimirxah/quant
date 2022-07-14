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
		die "No arg for --$OPT option. Use --$OPT=\$ARG for long notation."
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
	cat $file_template | while read -r LINE; do
		#for multiple matches of pattern use grep to store it in variable and iter on it
            	MATCHES=$(echo $LINE | grep -Eio "$BPAT(\w*)$EPAT")
            	for i in $MATCHES;do
                	eval VALMATCH=$(echo $i | sed -e "s/$BPAT\(\w*\)$EPAT/\$\U\1/g")
                	LINE="${LINE/$i/$VALMATCH}"
            	done
            	echo $LINE
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
		die "Can\`t write to result file $RESULT"
	fi
elif [[ ! -w "$RESULT" && $RESULT != "" ]]; then
	die "Can\`t write to result file $RESULT"
elif [[ $RESULT != "" ]]; then
	echo -n "" > $RESULT
	parse_file $TEMPLATE >> $RESULT
fi
