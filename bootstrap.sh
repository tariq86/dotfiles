#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

git pull origin master

function currentOS() {
	local userOS="?"
	if [ "$(uname)" == "Darwin" ]; then
		userOS="macos"
	elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
		userOS="linux"
	elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
		userOS="win32"
	elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
		userOS="win64"
	fi
	echo "$userOS"
}

function doIt() {
	local userOS="$(currentOS)"
	echo "USER_OS: ${userOS}"
	if [ "${userOS}" == "win32" -o "${userOS}" == "win64" ]; then
		echo "User OS: ${userOS} -- using 'robocopy' to sync files!"
		robocopy "." ".." "*.*" //xx //s //XD ".git" //XF \
			".DS_Store" \
			".macos" \
			".osx" \
			"bootstrap.sh" \
			"brew.sh" \
			"exclude.txt" \
			"LICENSE-MIT.txt" \
			"README.md"
	else
		rsync --exclude ".git/" \
			--exclude ".DS_Store" \
			--exclude ".osx" \
			--exclude "bootstrap.sh" \
			--exclude "README.md" \
			--exclude "LICENSE-MIT.txt" \
			--exclude "exclude.txt" \
			-avh --no-perms . ~
	fi
	source ~/.bash_profile
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt
	fi
fi
unset doIt
unset currentOS
