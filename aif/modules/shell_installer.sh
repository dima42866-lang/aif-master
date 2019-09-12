######################################################################
##                                                                  ##
##                 SHELL SETUP                                      ##
##                                                                  ##
######################################################################

# SHELL user installer

bash_setup()
{
    if [[ $_bsh_stp_once == "0" ]]; then
        _bsh_stp_once=1
        clear
        info_search_pkg
        _list_bash_sh=$(check_s_lst_pkg "${_bash_sh[*]}")
        wait
        _clist_bash_sh=$(check_q_lst_pkg "${_list_bash_sh[*]}")
        wait
        clear
        [[ ${_clist_bash_sh[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_clist_bash_sh[*]} 2>/tmp/.errlog
        check_for_error
         # BASH
        sed -i 's/PS1=/#PS1=/' ${MOUNTPOINT}/etc/bash.bashrc
        echo "alias ls='ls --color=auto'" >> ${MOUNTPOINT}/etc/bash.bashrc
        echo "PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\\$\[\e[m\] \[\e[1;37m\]'" >> ${MOUNTPOINT}/etc/bash.bashrc
    fi
}
zsh_setup()
{
    if [[ $_zsh_stp_once == "0" ]]; then
        _zsh_stp_once=1
        clear
        info_search_pkg
        _list_zsh_sh=$(check_s_lst_pkg "${_zsh_sh[*]}")
        wait
        _clist_zsh_sh=$(check_q_lst_pkg "${_list_zsh_sh[*]}")
        wait
        clear
        [[ ${_clist_zsh_sh[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_clist_zsh_sh[*]} 2>/tmp/.errlog
        check_for_error
         # ZSH
        _user_list=$(ls ${MOUNTPOINT}/home/ | sed "s/lost+found//")
        for i in ${_user_list[*]}; do
            echo "alias ls='ls --color=auto'" >> ${MOUNTPOINT}/home/$i/.zshrc
        done
    fi
}
fish_setup()
{
    if [[ $_fsh_stp_once == "0" ]]; then
        _fsh_stp_once=1
        clear
        info_search_pkg
        _list_fish_sh=$(check_s_lst_pkg "${_fish_sh[*]}")
        wait
        _clist_fish_sh=$(check_q_lst_pkg "${_list_fish_sh[*]}")
        wait
        clear
        [[ ${_clist_fish_sh[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_clist_fish_sh[*]} 2>/tmp/.errlog
        check_for_error
         #FISH
        echo "alias ls='ls --color=auto'" >> ${MOUNTPOINT}/etc/fish/config.fish
    fi
}
screenfetch_dialog()
{
    # Dialog yesno to screenfetch setup
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_yesno_scrfetch_ttl" --yesno "$_yesno_scrfetch_bd" 0 0
    if [[ $? -eq 0 ]]; then
       clear
        info_search_pkg
        _list_scr_strtp=$(check_s_lst_pkg "${_screen_startup[*]}")
        wait
        _scrnf_once=1
        clear
        [[ ${_list_scr_strtp[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_scr_strtp[*]} 2>/tmp/.errlog
        clear
    fi
}
select_install_shell()
{
    # Select dialog shell
    dialog --default-item ${HIGHLIGHT_SUB} --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_select_shell_menu_ttl" --menu "$_select_shell_menu_bd $1\n" 0 0 3 \
    "1" $"${_shells_sh[0]}" \
    "2" $"${_shells_sh[1]}" \
    "3" $"${_shells_sh[2]}" 2>${ANSWER}
    variable=($(cat ${ANSWER}))
    case $variable in 
        "1") bash_setup
             arch-chroot $MOUNTPOINT /bin/bash -c "chsh -s /bin/bash $1" 2>/tmp/.errlog
            ;;
        "2") zsh_setup
             arch-chroot $MOUNTPOINT /bin/bash -c "chsh -s /usr/bin/zsh $1" 2>/tmp/.errlog
            ;;
        "3") fish_setup
             arch-chroot $MOUNTPOINT /bin/bash -c "chsh -s /usr/bin/fish $1" 2>/tmp/.errlog
            ;;
    esac
    check_for_error
}
shell_friendly_setup()
{
    if [[ $_once_conf_fscr == "0" ]]; then
        _once_conf_fscr=1
        _usr_list=$(ls ${MOUNTPOINT}/home/ | sed "s/lost+found//")
        _usr_lst_menu=""
        for i in ${_usr_list[*]}; do
            _usr_lst_menu="${_usr_lst_menu} $i - on"
        done
        _usr_lst_menu="${_usr_lst_menu} root - off"
        screenfetch_dialog
    fi
    # Checklist dialog user
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_menu_ch_usr_ttl" --checklist "$_menu_ch_usr_bd" 0 0 16 ${_usr_lst_menu} 2>${ANSWER}
    _ch_usr=$(cat ${ANSWER})
    if [[ ${_ch_usr[*]} != "" ]]; then
        for i in ${_ch_usr[*]}; do
            select_install_shell "$i"
        done
	fi
}
