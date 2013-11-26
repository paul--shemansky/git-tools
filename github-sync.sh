#!/bin/bash

# Add the to your crontab to sync all your repos in a specified
# GIT_BASE_DIRECTORY every 5 minutes.
#
# */5 *  *   *   *     ~/git/git-tools/github-sync.sh

GIT_BASE_DIRECTORY=~/git
GITHUB_USERNAME=
LOG=~/var/log/liferay-github-sync/log.txt
LOCKFILE=~/var/lock/liferay-github-sync/github-sync.lock

function checkout {
	git clone git@github.com:$GITHUB_USERNAME/$i.git
}

function sync {
	source $HOME/.keychain/${HOSTNAME}-sh
	echo "Synchronizing $i" >> $LOG 2>&1
	cd $GIT_BASE_DIRECTORY/$i
	pwd >> $LOG 2>&1
	git fetch --all >> $LOG 2>&1
	git push -f origin upstream/master:master >> $LOG 2>&1
	git fetch origin >> $LOG 2>&1
}

function sync_all {
	echo "HOME=$HOME" >> $LOG 2>&1
	echo "GIT_BASE_DIRECTORY=$GIT_BASE_DIRECTORY" >> $LOG 2>&1
	echo `date +%Y%m%d%H%M%S` >> $LOG 2>&1
	
	for i in ${TRUNK[@]}; do
		sync $i
	done
}

declare -a TRUNK=(
					'liferay-plugins'
					'liferay-plugins-ee'
					'liferay-portal'
					'liferay-portal-ee'
					);

exec 200>$LOCKFILE
flock -x -n 200 || exit 0
pid=$$
echo $pid 1>&200
sync_all