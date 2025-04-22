#!/bin/sh

Conf_Dir="${HOME}/.config"

mkdir "${Conf_Dir}" > /dev/null 2>&1

ln -s "${PWD}/git" "${Conf_Dir}" > /dev/null 2>&1
ln -s "${PWD}/pandoc" "${Conf_Dir}" > /dev/null 2>&1
ln -s "${PWD}/nvim" "${Conf_Dir}" > /dev/null 2>&1
ln -s "${PWD}/starship/starship.toml" "${Conf_Dir}" > /dev/null 2>&1
ln -s "${PWD}/tmux" "${Conf_Dir}" > /dev/null 2>&1
ln -s "${PWD}/tss" "${Conf_Dir}" > /dev/null 2>&1
ln -s "${PWD}/perc" "${Conf_Dir}" > /dev/null 2>&1
ln -s "${PWD}/notes" "${Conf_Dir}" > /dev/null 2>&1
ln -s "${PWD}/picom" "${Conf_Dir}" > /dev/null 2>&1
ln -s "${PWD}/sxhkd" "${Conf_Dir}" > /dev/null 2>&1
# ln -s "${PWD}/zathura" "${Conf_Dir}" > /dev/null 2>&1
ln -s "${PWD}/qutebrowser" "${Conf_Dir}" > /dev/null 2>&1
ln -s "${PWD}/zsh/.zshrc" "${HOME}" > /dev/null 2>&1
ln -s "${PWD}/xinit/.xinitrc" "${HOME}" > /dev/null 2>&1

# Checking whether we are on Android or not
# This is how pfetch checks for Android
if [ -d /system/app ] && [ -d /system/priv-app ]; then
    mkdir "${HOME}/.termux" > /dev/null 2>&1
    ln -s "${PWD}/termux/colors.properties" "${HOME}/.termux" > /dev/null 2>&1
    ln -s "${PWD}/termux/termux.properties" "${HOME}/.termux" > /dev/null 2>&1
fi
