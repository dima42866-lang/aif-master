﻿######################################################################
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
    fi
}
screenfetch_setup()
{
    if [[ $_scrnf == "1" ]]; then
        clear
        case $1 in
            "bash") if [[ $_bool_bash == "0" ]]; then
                      echo "/usr/bin/screenfetch" >> ${MOUNTPOINT}/etc/bash.bashrc 2>/tmp/.errlog
                      _bool_bash=1
                    fi
                ;;
            "zsh") if [[ $_select_user != "root" ]]; then
                     echo "/usr/bin/screenfetch" >> ${MOUNTPOINT}/home/$2/.zshrc 2>/tmp/.errlog
                   fi
                ;;
            "fish") if [[ $_bool_fish == "0" ]]; then
                      echo "/usr/bin/screenfetch" >> ${MOUNTPOINT}/etc/fish/config.fish 2>/tmp/.errlog
                      _bool_fish=1
                    fi
                ;;
        esac
        check_for_error
    fi
}
screenfetch_dialog()
{
    # Dialog yesno to screenfetch setup
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_yesno_scrfetch_ttl" --yesno "$_yesno_scrfetch_bd" 0 0
    if [[ $? -eq 0 ]]; then
        dialog --defaultno --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_scrn_strp_ttl" --yesno "$_scrn_strp_bd" 0 0
        if [[ $? -eq 0 ]]; then
            _scrnf=1
        fi
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
             screenfetch_setup "bash" "$1"
            ;;
        "2") zsh_setup
             arch-chroot $MOUNTPOINT /bin/bash -c "chsh -s /usr/bin/zsh $1" 2>/tmp/.errlog
             screenfetch_setup "zsh" "$1"
            ;;
        "3") fish_setup
             arch-chroot $MOUNTPOINT /bin/bash -c "chsh -s /usr/bin/fish $1" 2>/tmp/.errlog
             screenfetch_setup "fish" "$1"
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
    for i in ${_ch_usr[*]}; do
        select_install_shell "$i"
    done
}