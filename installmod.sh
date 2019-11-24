#!/bin/bash
TLMMver=v0.1
curlofile=/tmp/curloutput-installmod-$USER.tmp
resultsfile=/tmp/resultsoutput-installmod-$USER.tmp

searchgithub () {
	# using a dump file due to the sheer size of the output.
	touch $curlofile
	[ ! -w $curlofile ] && errorexit 4 curlofile

	searchterm=$(echo $* | sed 's/[ ]/+/g')
	curl https://github.com/search?q=$searchterm > $curlofile 2> /dev/null || errorexit 2
	[ ! -s $curlofile ] && errorexit 2
	resultsformatting
}

resultsformatting () {
	# step 1: parsing the repo names
	declare -a reporesults
	reporesults=( $(cat $curlofile |\
		grep -i url |\
		grep -i "$searchterm" |\
		sed 's/^.*github.com\/search//g;s/^.*href\=\"\///g;s/\".*//g;s/^.*\}\}//g;/^$/d') )
	# If the query yeilds no results, the user is notified and program exits.
	[ -z "$reporesults" ] && errorexit 5

	# step 2: looping each repo in the array to parse its repo description.
	declare -a descresults
	descresults=()
	ct=0

# Faster but not used to this syntax yet. To be worked on later.
#	while IFS= read -r line; do
#		descresults+=( "$line" )
#		((ct++))
#		echo $ct
#	done < <(command)

	# Internal field seperator needs to seperate the descresults array with newlines.
	${IFS+"false"} && unset oldifs || oldifs="$IFS"
	IFS=$'\r\n'
	for i in "${reporesults[@]}"; do
#		echo -e "DEBUG1: \\n$i"
		descresults+=( $(cat $curlofile |\
			 grep -A 5 -m 1 "$i" |\
			 tail -n -1 |\
			 sed "s/^/no description/;s/^no description        //") );
	# The above sed expression allows empty results to be appended into the array.
	# Since the results that return text are input with 8 spaces at the beginning of the
	#   strings, this exploits that and isolates the empty results.
	done

	# Returning our internal field seperator to normal.
	${oldifs+"false"} && unset IFS || IFS="$oldifs"
	[ -z "$descresults" ] && errorexit 2 
	returnresults
}

returnresults () {
	# informing th0e user max 10 results only when >= 10
	printf '\n %s %s' "${#reporesults[@]}" "results found"
	[ "${#reporesults[@]}" -ge 10 ] && printf ' %s' "(maximum of 10 displayed)"
	echo -e "\\n"

	# Creating temp file to save state after query. Must ensure removal as we're appending.
	[ -s $resultsfile ] && rm -f $resultsfile
	touch $resultsfile
	[ ! -w $resultsfile ] && errorexit 4 resultsfile


	# loop it
	rcount=0
	scount=1
	for i in "${reporesults[@]}"; do
		echo "$scount - ${reporesults[$rcount]}"
		echo -e "   ${descresults[$rcount]}\\n" | cut -c 1-90
		# output links into save state file
		echo "https://github.com/${reporesults[$rcount]}" >> $resultsfile
		((rcount++))
		((scount++))
	done
	exit 0
}

clonemod () {
	# Checking that user input is not greater than the number of results
	[ -d ./repos ] && cd ./repos || errorexit 9
	gitlinksdb=gitlinks.db
	resultscount=$(wc -l < "$resultsfile")
	[ "$1" -gt "$resultscount" ] && errorexit 6

	# retrieving the git link
	githublink=$(head -n $1 "$resultsfile" | tail -1)
#	echo "$githublink" # for debug purposes

	# clone the repo
	git clone "$githublink" || errorexit 8

	# write to the database file
	touch "$gitlinksdb"
	[ ! -w "$gitlinksdb" ] && errorexit 4 gitlinks
	reponameparse=$(echo "$githublink" | awk -F "/" '{print $5}')
	grep "$githublink" < "$gitlinksdb"
	if [ $? -ne 0 ]; then
		echo "$reponameparse $githublink" >> "$gitlinksdb"
	fi
	cd ..
	exit 0
}

errorexit () {
	if [ "$1" == 1 ]; then
		echo "ERR: installmod: a query required for that option." 1>&2
		exit 1
	elif [ "$1" == 2 ]; then
		echo "ERR: installmod: no information present in var or $curlofile." 1>&2
		exit 2
	elif [ "$1" == 3 ]; then
		echo "ERR: installmod: no such option $1" 1>&2
		echo " provide '-h' or '--help' for options" 1>&2
		exit 3
	elif [ "$1" == 4 ]; then
		[ "$2" == "curlofile" ] && echo "ERR: installmod: cannot write to $curlofile" 1>&2
		[ "$2" == "resultsfile" ] && echo "ERR: installmod: cannot write to $resultsfile" 1>&2
		[ "$2" == "gitlinks" ] && echo "ERR: installmod: cannot access gitlinks.db file" 1>&2
		exit 4
	elif [ "$1" == 5 ]; then
		echo -e "\\n Your query did not return any results from github.\\n" 1>&2
		exit 5
	elif [ "$1" == 6 ]; then
		echo "ERR: installmod: not a valid selection." 1>&2
		exit 6
	elif [ "$1" == 7 ]; then
		echo "ERR: installmod: there are no query results to select; use '-q' option." 1>&2
		exit 7
	elif [ "$1" == 8 ]; then
		echo "ERR: installmod: error reported from git during install!" 1>&2
		exit 8
	elif [ "$1" == 9 ]; then
		echo "ERR: installmod: can't find the /repos directory." 1>&2
		exit 9
	else
		echo "ERR: installmod: undefined error. exiting." 1>&2
	fi
	exit 99
}

while [ $# -gt 0 ]; do
	case "$1" in
		-h|--help)
			echo -e "\\n installmod - Talz's Linux Mod Manager $TLMMver\\n"
			echo -e "          By Talzahr of Kel'Thuzad\\n"
			echo "USAGE"
			echo " installmod -s (integer)"
			echo -e " installmod searchterm\\n"
			echo -e " installmod will query github and list relevent repositories for installation.\\n"
			echo -e " Without options, github will be queried with your search term.\\n"
			echo "OPTIONS"
			echo "		-h --help     this message"
			echo "		-s --select   select from the list of query results for installation"
			echo -e "		-q --query    search github for repositories (default behavior).\\n"
			exit 0
			;;
		-q|-query)
			 [ ! $2 ] && errorexit 1
			shift
			searchgithub $*
			;;
		-s|--select)
			# Must be an integer 1-10 
			[ ! $2 ] && errorexit 6
			[[ ! $2 =~ ^[0-9]+$ ]] && errorexit 6
			[ "$2" -gt 10 ] && errorexit 6
			[ "$2" -lt 1 ] && errorexit 6
			[ ! -s "$resultsfile" ] && errorexit 7
			clonemod $2
			;;
		--)
			[ ! $2 ] && errorexit 1
			shift
			searchgithub $*
			;;
		-*)
			errorexit 3
			exit 3
			;;
		*)
			searchgithub $*
	esac
done
echo "ERR: installmod: fatal error." 1>&2
exit 100
