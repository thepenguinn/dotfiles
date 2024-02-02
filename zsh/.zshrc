#                _
#       _______| |__  _ __ ___
#     |_  / __| '_ \| '__/ __|
#   _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#

autoload -U compinit && compinit
zmodload -i zsh/complist

set -o vi

# ALIASES

alias ls="exa -laH --group-directories-first"
alias nvim="TERM=screen-256color nvim"

# EXPORTS

export "PATH=${PATH}:${HOME}/.local/bin:${HOME}/go/bin:${HOME}/.cargo/bin"
export "GTYPIST_PATH=/data/data/com.termux/files/usr/share/gtypist:"
export "MATHLIB=m"
export "TERM=xterm-256color"

export ANDROID_SDK_ROOT=${HOME}/android-sdk
export ANDROID_HOME=${HOME}/android-sdk
export PATH=${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}

#export MANPAGER="nvimpager"
#export PAGER="nvimpager"

# SOURCES

# TODO: REMOVE THIS FROM HERE

export JF_MAC_ADDR="00:0a:f5:89:89:ff"
export JF_USER_NAME="u0_a246"

ssh() {
	local user_name="$JF_USER_NAME"
	local jf_mac_addr="$JF_MAC_ADDR"

	ssh-add -l > /dev/null 2>&1 || ssh-add

	if [[ "$1" == "jf" ]]; then
		if [[ "$#" -gt 1 ]]; then
			command ssh -o StrictHostKeyChecking=no -p 8022 ${user_name}@$(ip neigh | grep "${jf_mac_addr}" | grep "\." | cut -d" " -f1) $(printf "$@" | sed "s/^jf//")
		else
			command ssh -o StrictHostKeyChecking=no -p 8022 ${user_name}@$(ip neigh | grep "${jf_mac_addr}" | grep "\." | cut -d" " -f1)
		fi
	else
		command ssh "$@"
	fi
}

# This doesn't work because of zsh :(
# I'll fix it later
# well, I think this kinda works, kinda works...
rsync() {
	local remote=""
	local source=""
	local user_name="$JF_USER_NAME"
	local jf_mac_addr="$JF_MAC_ADDR"
	local i
	local lastarg=${@[$#]}

	ssh-add -l > /dev/null 2>&1 || ssh-add

	if [[ "$1" =~ "^ *jf:" ]]; then
		remote="$user_name@$(ip neigh | grep "$jf_mac_addr" | grep "\." | cut -d" " -f1)"

		for i in $(seq 1 $((#-1)))
		do
			source+=" :\"$(echo "${@[$i]}" | sed 's/^jf://;s/^://')\""
		done

		eval "command rsync -rvuP -e \"ssh -p 8022 -o StrictHostKeyChecking=no\" "${remote}$(echo ${source} | sed s@^\ @@)" "${lastarg}""

	elif [[ "${lastarg}" =~ "^ *jf:" ]]; then

		remote="$user_name@$(ip neigh | grep "$jf_mac_addr" | grep "\." | cut -d" " -f1):$(echo "${lastarg}" | sed 's/^jf://')"

		[[ ! $remote =~ /$ ]] && remote="${remote}/"

		for i in $(seq 1 $((#-1)))
		do
			[[ ${@[$i]} =~ ^/ ]] && source+="\"${@[i]}\" " || source+="\"$PWD/${@[i]}\" "
		done

		eval "command rsync -rvuP -e \"ssh -p 8022 -o StrictHostKeyChecking=no\" "${source}" "${remote}""

	else
		command rsync -rvuP "$@"
	fi
}

# BLINKY BLANKY LINES

eval "$(starship init zsh)"
eval "$(ssh-agent -s)"

clear
pfetch
printf "\033[31;1m  hello friend.\n"
#tsu -s /system/xbin/bash
