#!/bin/env sh

# Script for installing dotman
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/smenzer/dotman/master/tools/install.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/smenzer/dotman/master/tools/install.sh)"
# or httpie:
#   sh -c "$(http --download https://raw.githubusercontent.com/smenzer/dotman/master/tools/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/smenzer/dotman/master/tools/install.sh
#   sh install.sh
#
# Respects the following environment variables:
#   DOTMAN  - path to the dotman repository folder (default: $HOME/src/github.com/smenzer/dotman)
#   REPO    - name of the GitHub repo to install from (default: smenzer/dotman)
#   BRANCH  - the branch of upstream dotman repo.
#   REMOTE  - full remote URL of the git repo to install (default: GitHub via HTTPS)


DOTMAN=${DOTMAN:-$HOME/src/github.com/smenzer/dotman}
REPO=${REPO:-smenzer/dotman}
BRANCH=${BRANCH:-master}
REMOTE=${REMOTE:-git@github.com:${REPO}.git}


status_checks() {
	if [ -d "$DOTMAN" ] && [ -f "${DOTMAN}/dotman.sh" ]; then
		cat <<-EOF
			You already have d○tman 🖖 installed.
			You'll need to remove '$DOTMAN' if you want to reinstall.
		EOF
		exit 1
	fi

	if ! command -v git 2>&1 /dev/null
	then
		echo "Can't work without Git 😞"
		exit 1
	else
		# Make sure destination directory exists, if not create it
		if [ ! -d "${DOTMAN}" ]; then
			mkdir -p ${DOTMAN}
		fi

		# Clone repository to ${DOTMAN} destination
		git clone "$REMOTE" --branch ${BRANCH} --single-branch "${DOTMAN}"
		echo "[✔️ ] Repository cloned to $(tput bold)${DOTMAN}$(tput sgr0)"
	fi
}

set_alias(){
	DOTMAN_ALIAS_NAME='dotman'
	ALIAS_FILES=( "${HOME}/.bash_aliases", "${HOME}/.bash_profile", "${HOME}/.bashrc", "${HOME}/.zshrc", "${ZDOTDIR}/.zshrc" )

	for f in "${ALIAS_FILES}"; do
		if [ -f "${f}" ]; then
			if [ -n "$(eval "grep '^alias ${DOTMAN_ALIAS_NAME}=' ${f} 2>/dev/null")" ]; then
				echo "[✔️ ] Alias already set for ${f}";
			else
				echo "alias ${DOTMAN_ALIAS_NAME}='${DOTMAN}/dotman.sh'" >> "${f}"
				echo "[✔️ ] Alias added to ${f}";
			fi
			ALIAS_SET=1
		fi
	done

	if [ -z ${ALIAS_SET} ]; then
		echo "Couldn't set any aliases to dotman $(tput bold)${DOTMAN}/dotman.sh$(tput sgr0) due to missing rc files:"
		for f in " - $(tput bold)${ALIAS_FILES}$(tput sgr0)"; do
			echo ${f}
		done
		echo "Consider adding it manually".
	fi
}

main () {

	status_checks
	set_alias

	cat <<-'EOF'

	      _       _
	     | |     | |
	   __| | ___ | |_ _ __ ___   __ _ _ __
	  / _` |/ _ \| __| '_ ` _ \ / _` | '_ \
	 | (_| | (_) | |_| | | | | | (_| | | | |
	  \__,_|\___/ \__|_| |_| |_|\__,_|_| |_|
	                                         .... is now installed


	Run `dotman version` to check latest version.
	Run `dotman` to configure first time setup.

	EOF
}

main
