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
		r | result )		needs_arg; RESULT="$OPTARG" ;;
		??* )						die "Illegal option --$OPT" ;;
		? )							exit 2 ;;	# bad short option (error reported via getopts)
	esac
done
shift $((OPTIND-1))
#if [[ ! -r $1 ]]; then
#	echo "Can\`t find file to parse"
#	exit_abnormal
#fi
#if [[ ! -w $2 ]]; then
#	echo "Can\`t write to target file"
#	exit_abnormal
#fi
