#                _
#       _______| |__  _ __ ___
#     |_  / __| '_ \| '__/ __|
#   _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#

if [[ -z $TMUX ]] && ! tmux has-session -t general 2>/dev/null; then
    ~/.local/bin/tss utils:proot general
fi

autoload -U compinit && compinit
zmodload -i zsh/complist

set -o vi

# ALIASES

alias ls="exa -laH --group-directories-first"
alias nvim="TERM=screen-256color nvim"
alias kdb="kdb syncall"

# EXPORTS

export PATH="${PATH}:${HOME}/.local/bin:${HOME}/go/bin:${HOME}/.cargo/bin"
export GTYPIST_PATH="/data/data/com.termux/files/usr/share/gtypist:"
export MATHLIB="m"
export TERM="xterm-256color"
export EDITOR="TERM=screen-256color nvim"

export ANDROID_SDK_ROOT=${HOME}/android-sdk
export ANDROID_HOME=${HOME}/android-sdk
export PATH=${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}

#export MANPAGER="nvimpager"
#export PAGER="nvimpager"

# SOURCES

export MOTO_MAC_ADDR="88:79:7e:be:5e:e4"
export MOTO_USER_NAME="u0_a152"

export JF_MAC_ADDR="00:0a:f5:89:89:ff"
export JF_USER_NAME="u0_a246"

export KINDLE_MAC_ADDR="f4:03:2a:d5:42:6c"
export LOCAL_KINDLE_DIR="$HOME/storage/shared/kindle"

ssh() {
	local jf_user_name="$JF_USER_NAME"
	local jf_mac_addr="$JF_MAC_ADDR"

	local moto_user_name="$MOTO_USER_NAME"
	local moto_mac_addr="$MOTO_MAC_ADDR"

    local void_user_name="daniel"

	if [[ "$1" == "jf" ]]; then
        ssh-add -l | grep "root@localhost" > /dev/null 2>&1 || ssh-add
		if [[ "$#" -gt 1 ]]; then
			command ssh -o StrictHostKeyChecking=no -p 8022 "${jf_user_name}@$(ip neigh | grep "${jf_mac_addr}" | grep "\." | cut -d" " -f1)" $(echo "$@" | sed "s/^jf//")
		else
			command ssh -o StrictHostKeyChecking=no -p 8022 ${jf_user_name}@$(ip neigh | grep "${jf_mac_addr}" | grep "\." | cut -d" " -f1)
		fi
	elif [[ "$1" == "moto" ]]; then
        ssh-add -l | grep "root@localhost" > /dev/null 2>&1 || ssh-add
		if [[ "$#" -gt 1 ]]; then
			command ssh -o StrictHostKeyChecking=no -p 8022 "${moto_user_name}@$(ip neigh | grep "${moto_mac_addr}" | grep "\." | cut -d" " -f1)" $(echo "$@" | sed "s/^moto//")
		else
			command ssh -o StrictHostKeyChecking=no -p 8022 ${moto_user_name}@$(ip neigh | grep "${moto_mac_addr}" | grep "\." | cut -d" " -f1)
		fi
	elif [[ "$1" == "void" ]]; then
        ssh-add -l | grep "root@localhost" > /dev/null 2>&1 || ssh-add
		if [[ "$#" -gt 1 ]]; then
			command ssh -o StrictHostKeyChecking=no -p 22 "${void_user_name}@$(ip neigh | grep "${moto_mac_addr}" | grep "\." | cut -d" " -f1)" $(echo "$@" | sed "s/^void//")
		else
			command ssh -o StrictHostKeyChecking=no -p 22 ${void_user_name}@$(ip neigh | grep "${moto_mac_addr}" | grep "\." | cut -d" " -f1)
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
	local i
	local lastarg=${@[$#]}

    local jf_user_name="$JF_USER_NAME"
    local jf_mac_addr="$JF_MAC_ADDR"

	local moto_user_name="$MOTO_USER_NAME"
	local moto_mac_addr="$MOTO_MAC_ADDR"

    local void_user_name="daniel"

	ssh-add -l | grep "root@localhost" > /dev/null 2>&1 || ssh-add

	if [[ "$1" =~ "^ *jf:" ]]; then
        # jf
		remote="$jf_user_name@$(ip neigh | grep "$jf_mac_addr" | grep "\." | cut -d" " -f1)"

		for i in $(seq 1 $((#-1)))
		do
			source+=" :\"$(echo "${@[$i]}" | sed 's/^jf://;s/^://')\""
		done

		eval "command rsync -rvuP -e \"ssh -p 8022 -o StrictHostKeyChecking=no\" "${remote}$(echo ${source} | sed s@^\ @@)" "${lastarg}""

	elif [[ "${lastarg}" =~ "^ *jf:" ]]; then
        # jf

		remote="$jf_user_name@$(ip neigh | grep "$jf_mac_addr" | grep "\." | cut -d" " -f1):$(echo "${lastarg}" | sed 's/^jf://')"

		[[ ! $remote =~ /$ ]] && remote="${remote}/"

		for i in $(seq 1 $((#-1)))
		do
			[[ ${@[$i]} =~ ^/ ]] && source+="\"${@[i]}\" " || source+="\"$PWD/${@[i]}\" "
		done

		eval "command rsync -rvuP -e \"ssh -p 8022 -o StrictHostKeyChecking=no\" "${source}" "${remote}""

	elif [[ "$1" =~ "^ *moto:" ]]; then
        # moto
		remote="$moto_user_name@$(ip neigh | grep "$moto_mac_addr" | grep "\." | cut -d" " -f1)"

		for i in $(seq 1 $((#-1)))
		do
			source+=" :\"$(echo "${@[$i]}" | sed 's/^moto://;s/^://')\""
		done

		eval "command rsync -rvuP -e \"ssh -p 8022 -o StrictHostKeyChecking=no\" "${remote}$(echo ${source} | sed s@^\ @@)" "${lastarg}""

	elif [[ "${lastarg}" =~ "^ *moto:" ]]; then
        # moto

		remote="$moto_user_name@$(ip neigh | grep "$moto_mac_addr" | grep "\." | cut -d" " -f1):$(echo "${lastarg}" | sed 's/^moto://')"

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

# In $HOME/.bashrc file

function gradlew {
    file="./gradlew"
    if test -f "$file" ; then
        bash $file -Pandroid.aapt2FromMavenOverride=$HOME/./android-sdk/build-tools/34.0.4/aapt2 $@
    else
        echo "Invoke this command from a project's root directory."
    fi
}

export gradlew

function dg () {

    local query=$(echo "${@}" | tr ' ' ''+)

    w3m "https://lite.duckduckgo.com/lite/?q=${query}"
}

# if we are inside a proot environment
if [[ $(whoami) == "daniel" && -d /data/data/com.termux/files/usr/bin ]]; then
    export PATH="${PATH}:/data/data/com.termux/files/usr/bin"
    cd
fi

# BLINKY BLANKY LINES

eval "$(starship init zsh)" > /dev/null
eval "$(ssh-agent -s)" > /dev/null

clear
pfetch
printf "\033[31;1m  hello friend.\n"
#tsu -s /system/xbin/bash
