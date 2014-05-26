function readlink() {

	TARGET_FILE=$1
	
	cd `dirname $TARGET_FILE`
	TARGET_FILE=`basename $TARGET_FILE`
	
	# Iterate down a (possible) chain of symlinks
	while [ -L "$TARGET_FILE" ]
	do
		TARGET_FILE=`readlink $TARGET_FILE`
		cd `dirname $TARGET_FILE`
		TARGET_FILE=`basename $TARGET_FILE`
	done
	
	# Compute the canonicalized name by finding the physical path 
	# for the directory we're in and appending the target file.
	PHYS_DIR=`pwd -P`
	RESULT=$PHYS_DIR/$TARGET_FILE
	echo $RESULT
}

function random_cowsay() {
	# /usr/local/Cellar/cowsay/3.03/share/cows
	#COWS=$(readlink -f $(which cowsay))/../../share/cows
	COWS=readlink $(which cowsay)/../../share/cows
	NBRE_COWS=$(ls -1 $COWS | wc -l)
	COWS_RANDOM=$(expr $RANDOM % $NBRE_COWS + 1)
	COW_NAME=$(ls -1 $COWS | awk -F\. -v COWS_RANDOM_AWK=$COWS_RANDOM 'NR == COWS_RANDOM_AWK {print $1}')

	if [ -f ~/.cowsay_name ]; then
		COW_NAME=$(sed -n '1p' ~/.cowsay_name)
	else
		COW_NAME=$(ls -1 $COWS | awk -F\. -v COWS_RANDOM_AWK=$COWS_RANDOM 'NR == COWS_RANDOM_AWK {print $1}')
	fi

	cowsay -f $COW_NAME "`Fortune -s`"
}

function nowon() {
	[ -x ~/.bash.d/bin/readlink ] || return 1
	if which fortune cowsay >/dev/null; then
		while :
		do
			random_cowsay 2>/dev/null && break
		done
	fi && unset random_cowsay
	LANG=C
	echo -e  "\033[33m$(date +'%Y/%m/%d %T')\033[m"
	echo -en "\n"; sleep 0.5; pwd; ls
	echo -en "\n"
}

function _refuge_complement() {
	local curw prev

	COMPREPLY=()
	curw=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [[ "$curw" == -* ]]; then
		COMPREPLY=( $( compgen -o default -W '-X -h --help --version --except' -- $curw ) )
	elif [[ "$prev" = "-X" || "$prev" = "--except" && $COMP_CWORD = 2 ]]; then
		COMPREPLY=( $( compgen -W '`\ls -AF ~/Dropbox/usr/init/unix/rc.d`' -- $curw ))
	fi

	return 0
}
complete -F _refuge_complement refuge

function _salvage_complement() {
	local curw prev

	COMPREPLY=()
	curw=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [[ "$curw" == -* ]]; then
		COMPREPLY=( $( compgen -o default -W '-h --help -t --target -n --number -d --depth -c --ctime' -- $curw ) )
	elif [[ "$prev" = "-t" || "$prev" = "--target" ]]; then
		COMPREPLY=( $( compgen -W 'vim bak debris' -- $curw ))
	elif [[ $COMP_CWORD = $(($# - 1)) ]]; then
		COMPREPLY=( $( compgen -W '`\ls -F ~`' -- $curw ))
	fi

	return 0
}
complete -F _salvage_complement salvage

function _todrop_complement() {
	local curw prev

	COMPREPLY=()
	curw=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [[ "$curw" == -* ]]; then
		COMPREPLY=( $( compgen -o default -W '-h --help --version -c --copy -f --force -v --verbose -p --path \
			-a --append -- -' -- $curw ) )
	elif [[ "$prev" = "-p" || "$prev" = "--path" ]]; then
		COMPREPLY=( $( compgen -W '`\ls -F ~/Dropbox`' "$curw" ))
	else
		COMPREPLY=( $( compgen -f $curw ) )
	fi

	return 0
}
complete -F _todrop_complement todrop

mkdir ()
{
	for arg do
		if [ -e "$arg" ]; then
			command mkdir -p "${arg}.d"
		else
			command mkdir -p "${arg}"
		fi
	done
}

calc(){ awk "BEGIN{ print $* }" ;}

function BLACK { echo -e "\e[30$*\e[m"; }
function RED { echo -e "\e[31m$*\e[m"; }
function GREEN { echo -e "\e[32m$*\e[m"; }
function YELLOW { echo -e "\e[33m$*\e[m"; }
function BLUE { echo -e "\e[34m$*\e[m"; }
function MAGENTA { echo -e "\e[35m$*\e[m"; }
function CYAN { echo -e "\e[36m$*\e[m"; }
function WHITE { echo -e "\e[37m$*\e[m"; }

function color_giver() {
	if [ $# -le 1 ]; then
		return 1
	elif [ $# -eq 3 ]; then
		option="$3;"
	fi
	text=$1
	color=$2
	case $color in
		1|[Bb]lack) color=30 ;;
		2|[Rr]ed) color=31 ;;
		3|[Gg]reen) color=32 ;;
		4|[Yy]ellow) color=33 ;;
		5|[Bb]lue) color=34 ;;
		6|[Mm]agenta) color=35 ;;
		7|[Cc]yan) color=36 ;;
		8|[Ww]hite) color=37 ;;
	esac
	
	echo -e "\033[${option}${color}m${text}\033[m"
}


function bg_rotation_bar() {
	### How to use this function
	###
	###>> . ./general.func
	###>> bg_rotation_bar
	###>> 
	###>> if sleep 10; then
	###>>   kill -9 $!
	###>>   exit 0
	###>> fi
	### Write the above contents to sh file.

	#trap 'kill -9 $!' 1 2 3 15
#exec 3>&1

	for ((current_count=0; ; current_count++)); do
		let type=current_count%4
		case "$type" in
			0) echo -ne "|\033[1D";;
			1) echo -ne "/\033[1D";;
			2) echo -ne "-\033[1D";;
			3) echo -ne "\\\\\033[1D";;
		esac
		sleep 0.01s
	done &
#exec 3>&1
}

function bg_clean() {
	### How to use this function
	###
	### !!case 1!!
	###>> . ~/.bash.d/lib/general.func
	###>> 
	###>> trap 'bg_clean' EXIT INT ERR
	###>> 
	###>> bg_rotation_bar
	###>> sleep 3
	###
	### !!case 2!!
	###>> . ~/.bash.d/lib/general.func
	###>> 
	###>> bg_rotation_bar
	###>> if sleep 3; then
	###>>   bg_clean
	###>> fi
	###
	[ ! -z "$!" ] && kill $!
}

function try_catch() {
	set -e
	set -o pipefail
	trap 'exit -1' ERR
}

function abs_path() {
	if [ -z "$1" ]; then
		return 1
	fi
	
	if [ `expr x"$1" : x'/'` -ne 0 ]; then
		local rel="$1"
	else
		local rel="$PWD/$1"
	fi
	
	local abs="/"
	local _IFS="$IFS"; IFS='/'
	
	for comp in $rel; do
		case "$comp" in
			'.' | '')
				continue
				;;
			'..'	)
				abs=`dirname "$abs"`
				;;
			*		)
				[ "$abs" = "/" ] && abs="/$comp" || abs="$abs/$comp"
				;;
		esac
	done
	echo "$abs"
	IFS="$_IFS"
}

function rel_path() {
	if [ -z "$1" ]; then
		return 1
	fi

	if [ `expr x"$1" : x'/'` -eq 0 ]; then
		echo "$1: not an absolute path"
		return 1
	fi

	local org=`expr x"$PWD" : x'/\(.*\)'`
	local abs=`expr x"$1"   : x'/\(.*\)'`
	local rel="."
	local org1=""
	local abs1=""

	while true; do
		org1=`expr x"$org" : x'\([^/]*\)'`
		abs1=`expr x"$abs" : x'\([^/]*\)'`

		[ "$org1" != "$abs1" ] && break

		org=`expr x"$org" : x'[^/]*/\(.*\)'`
		abs=`expr x"$abs" : x'[^/]*/\(.*\)'`
	done

	if [ -n "$org" ]; then
		local _IFS="$IFS"; IFS='/'
		for c in $org; do
			rel="$rel/.."
		done
		IFS="$_IFS"
	fi

	if [ -n "$abs" ]; then
		rel="$rel/$abs"
	fi

	rel=`expr x"$rel" : x'\./\(.*\)'`
	echo "$rel"
}


function is_pipe() {
	if [ -p /dev/stdin ]; then
	#if [ -p /dev/fd/0  ]; then
	#if [ -p /proc/self/fd/0 ]; then
	#if [ -t 0 ]; then
		# echo a | is_pipe
		return 0
	elif [ -p /dev/stdout ]; then
		# is_pipe | cat
		return 0
	else
		# is_pipe (Only!)
		return 1
	fi
}

function in_pipe() {
	# echo a | in_pipe
	if [ -p /dev/stdin ]; then
		return 0
	else
		return 1
	fi
}

function out_pipe() {
	# out_pipe | cat
	if [ -p /dev/stdout ]; then
		return 0
	else
		return 1
	fi
}

function nonewline() {
	if [ "$(echo -n)" = "-n" ]; then
		echo "${@:-> }\c"
	else
		echo -n "${@:-> }"
	fi
}

function is_num() {
	expr "$1" \* 1 >/dev/null 2>&1
	if [ $? -ge 2 ]; then
		return 1
	else
		return 0
	fi
}

function is_num2() {
	[ "$1" -eq 0 ] 2>/dev/null
	if [ $? -ge 2 ]; then
		# $1 is a NOT a valid integer.
		return 1
	else
		# $1 is a valid integer.
		return 0
	fi
}

function strcmp() {
	# abc == abc (return  0)
	# abc =< def (return -1)
	# def >= abc (return  1)
	if [ $# -ne 2 ]; then
		echo "Usage: strcmp string1 string2" 1>&2
		exit 1
	fi
	if [ "$1" = "$2" ]; then
		#return 0
		echo "0"
	else
		local _TMP=`{ echo "$1"; echo "$2"; } | sort -n | sed -n '1p'`

		if [ "$_TMP" = "$1" ]; then
			#return -1
			echo "-1"
		else
			#return 1
			echo "1"
		fi
	fi
}

function strlen() {
	local length=`echo "$1" | wc -c | sed -e 's/ *//'`
	echo `expr $length - 1`
}

function Atoa() {
	echo $* | tr '[A-Z]' '[a-z]'
}

function atoA() {
	echo $* | tr '[a-z]' '[A-Z]'
}
