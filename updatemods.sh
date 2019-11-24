#!/bin/bash
gitlinks=./repos/gitlinks.db
mkdir -p ./repos &> /dev/null
mkdir -p ./sync &> /dev/null
mkdir -p ./backups &> /dev/null
touch $gitlinks

installrepo () {
exit 0
}

pullrepos () {
counter=1
exit 0
}

syncrepos () {
exit 0
}

while [ $# -gt 0 ]; do
	case "$1" in
		-h|--help)
			echo -e " updatemods v0.1 by talzahr on KelThuzad\\n"
			echo -e " usage [options] [repo name]\\n"
			echo "	OPTIONS"
#			echo "		-c             clone all repos listed in ./repos/gitlinks.db"
			echo "		-h --help      this message"
			echo "		-i --install   install a new AddOn repo"
			echo "		-s             sync all repos to the WoW AddOns directory"
			echo "		-S             sync a specific repo to WoW's AddOns directory"
			echo "		-u             update all repos in ./repos"
			echo -e "		-U             update a specific repo\\n"
			echo " Not every AddOn has a github repo. Those that do are alpha development"
			echo " 	and are not considered stable releases."
			exit 0
			;;
	esac
done
