#!/bin/bash
#
#  Build script for time2backup server docker image
#
#  Website: https://time2backup.org
#  MIT License
#  Copyright (c) 2017-2021 Jean Prunneaux
#


# go into current directory
cd "$(dirname "$0")" || exit 1


#
#  Functions
#

# Print usage
print_help() {
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "   -v, --version VERSION         Specify a version"
	echo "   -b, --branch stable|unstable  Specify a branch (stable by default)"
	echo "   -h, --help                    Print this help"
}


#
#  Main program
#

branch=stable

# get options
while [ $# -gt 0 ] ; do
	case $1 in
		-v|--version)
			if [ -z "$2" ] ; then
				print_help
				exit 1
			fi
			version=$2
			shift
			;;
		-b|--branch)
			case $2 in
				stable|unstable)
					branch=$2
					shift
					;;
				*)
					print_help
					exit 1
					;;
			esac
			;;
		-h|--help)
			print_help
			exit
			;;
		*)
			break
			;;
	esac
	shift
done

# prompt to choose version
if [ -z "$version" ] ; then
	version=$(grep 'VERSION=' Dockerfile | head -1 | cut -d= -f2)

	echo -n "Choose version: [$version] "
	read version_user
	if [ -n "$version_user" ] ; then
		version=$version_user
	fi

	echo
fi

echo "Prepare Dockerfile..."
sed -i "s/BRANCH=.*/BRANCH=$branch/; s/VERSION=.*/VERSION=$version/" Dockerfile || exit

echo "Build image..."
docker pull "$(grep '^FROM ' Dockerfile | awk '{print $2}')" || exit
docker build -t time2backup/server:$version . || exit
