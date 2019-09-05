######################################################################
##                                                                  ##
##                    Installation Functions                        ##
##                                                                  ##
######################################################################  

multilib_question()
{
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_yesno_multilib_title" --yesno "$_yesno_multilib_body" 0 0

    if [[ $? -eq 0 ]]; then
        # echo "[multilib]" >> /etc/pacman.conf
        # echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
	# sed -i 's/^\#\[multilib\]$/[multilib]/' /etc/pacman.conf
        # sed -i '/^\[multilib\]$/a\Include = /etc/pacman.d/mirrorlist' /etc/pacman.conf
	sed -i '93s/\#\[multilib\]/[multilib]/' /etc/pacman.conf
        sed -i '94s/\#Include/Include/' /etc/pacman.conf
        _multilib=1
    else
        _multilib=0
    fi
}

mirrorlist_question()
{
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_MirrorlistTitle" --yesno "$_yesno_mirrorlist_body" 0 0

    if [[ $? -eq 0 ]]; then
        sudo cp -f /etc/pacman.d/mirrorlist ${MOUNTPOINT}/etc/pacman.d/mirrorlist
    fi
}

function check_s_lst_pkg {
    local temp_pkg
    temp_pkg=("$@")
    declare -a new_pkg
    temp=""
    for i in ${temp_pkg[*]}; do
        pacman -Ss $i 1>/dev/null 2>/dev/null
        err=$?
        if [[ $err -eq 0 ]]; then 
            new_pkg=("${new_pkg[*]}" "$i")
        fi
    done
    echo ${new_pkg[*]}
}
function check_q_lst_pkg {
    local temp_pkg
    temp_pkg=("$@")
    declare -a new_pkg
    temp=""
    for i in ${temp_pkg[*]}; do
        pacman --root ${MOUNTPOINT} --dbpath ${MOUNTPOINT}/var/lib/pacman -Qs $i 1>/dev/null 2>/dev/null
        err=$?
        [[ $err != "0" ]] && new_pkg=("${new_pkg[@]}" "$i")
    done
    echo ${new_pkg[*]}
}

info_search_pkg()
{
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_nfo_search_pkg_title" --infobox "$_nfo_search_pkg_body" 0 0
}

install_wireless_programm()
{
    if [[ $_net_cntrl == "0" ]]; then
        dialog --defaultno --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_yesno_iwp_title" --yesno "$_yesno_iwp_body" 0 0
        if [[ $? -eq 0 ]]; then
            _net_cntrl=1
            clear
            info_search_pkg
            _list_wifi_pkg=$(check_s_lst_pkg "${_wifi_pkg[*]}")
            wait
            clear
            [[ ${_list_wifi_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_wifi_pkg[*]} 2>/tmp/.errlog
        fi
    fi
}

search_translit_pkg()
{
    stp=$(pacman -Ss | grep -Ei "core|extra|community|multilib" | sed 's/extra\///' | sed 's/core\///' | sed 's/community\///' | sed 's/multilib\///' | grep -E "^$1" | awk '{print $1}' | grep -E "$2$")
    echo "${stp[*]}"
}

install_gengen()
{
    _gengen_menu=""
    if [[ $_gengen_once == "0" ]]; then
        _gengen_once=1
        clear
        info_search_pkg
        _list_general_pkg=$(check_s_lst_pkg "${_general_pkg[*]}")
        wait
        _gengen_menu=""
        for i in ${_list_general_pkg[*]}; do
            _gengen_menu="${_gengen_menu} ${i} - on"
        done
        wait
        clear
    fi
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_menu_gengen" --checklist "$_ch_mn_bd" 0 0 16 ${_gengen_menu} 2>${ANSWER}
    _ch_gengen=$(cat ${ANSWER})
    clear
    [[ ${_ch_gengen[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_ch_gengen[*]} 2>/tmp/.errlog
}
install_archivers()
{
    if [[ $_archivers_once == "0" ]]; then
        _archivers_once=1
        clear
        info_search_pkg
        _list_archivers_pkg=$(check_s_lst_pkg "${_archivers_pkg[*]}")
        wait
        _clist_archivers_pkg=$(check_q_lst_pkg "${_list_archivers_pkg[*]}")
        wait
        for i in ${_clist_archivers_pkg[*]}; do
            archivers_menu="${archivers_menu} ${i} - on"
        done
        wait
        clear
    fi
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_menu_archivers" --checklist "$_ch_mn_bd" 0 0 16 ${archivers_menu} 2>${ANSWER}
    _ch_archivers=$(cat ${ANSWER})
    clear
    [[ ${_ch_archivers[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_ch_archivers[*]} 2>/tmp/.errlog
}
win_fonts_setup()
{
    dialog --defaultno --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_yn_win_fnts_ttl" --yesno "$_yn_win_fnts_bd" 0 0
    if [[ $? -eq 0 ]]; then
       tar -C "${MOUNTPOINT}/usr/share/fonts" -xvzf $_win_fonts_pkg
        arch-chroot $MOUNTPOINT /bin/bash -c "fc-cache" 2>/tmp/.errlog
        check_for_error
    fi
}
install_ttftheme()
{
    if [[ $_ttf_once == "0" ]]; then
        _ttf_once=1
        clear
        info_search_pkg
        _list_ttf_theme_pkg=$(check_s_lst_pkg "${_ttf_theme_pkg[*]}")
        wait
        _clist_ttf_theme_pkg=$(check_q_lst_pkg "${_list_ttf_theme_pkg[*]}")
        wait
        for i in ${_clist_ttf_theme_pkg[*]}; do
            _ttf_menu="${_ttf_menu} ${i} - on"
        done
        wait
        clear
    fi
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_menu_ttf_theme" --checklist "$_ch_mn_bd" 0 0 16 ${_ttf_menu} 2>${ANSWER}
    _ch_ttf=$(cat ${ANSWER})
    clear
    [[ ${_ch_ttf[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_ch_ttf[*]} 2>/tmp/.errlog
    check_for_error
    win_fonts_setup
}
install_standartpkg()
{
    if [[ $_stpkg_once == "0" ]]; then
        _stpkg_once=1
        clear
        info_search_pkg
        _list_gr_editor=$(check_s_lst_pkg "${_gr_editor[*]}")
        wait
        [[ ${_list_gr_editor[*]} != "" ]] && _tr_gr_editor=$(search_translit_pkg "${_gr_editor[*]}" "$_user_local")
        wait
        [[ ${_tr_gr_editor[*]} != "" ]] && _list_gr_editor="${_list_gr_editor} ${_tr_gr_editor[*]}"
        _list_office=$(check_s_lst_pkg "${_office}")
        wait
        [[ ${_list_office[*]} != "" ]] && _tr_office=$(search_translit_pkg "${_office}" "$_user_local")
        wait
        [[ ${_tr_office[*]} != "" ]] && _list_office="${_list_office} ${_tr_office[*]}"
        _list_minimal_pkg=$(check_s_lst_pkg "${_minimal_pkg[*]}")
        wait
        [[ ${_list_gr_editor[*]} != "" ]] && _list_minimal_pkg="${_list_minimal_pkg} ${_list_gr_editor[*]}"
        [[ ${_list_office[*]} != "" ]] && _list_minimal_pkg="${_list_minimal_pkg} ${_list_office[*]}"
        wait
        _clist_minimal_pkg=$(check_q_lst_pkg "${_list_minimal_pkg[*]}")
        wait
        for i in ${_clist_minimal_pkg[*]}; do
            _standart_pkg_menu="${_standart_pkg_menu} ${i} - on"
        done
        wait
        clear
    fi
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_menu_add_pkg" --checklist "$_ch_mn_bd" 0 0 16 ${_standart_pkg_menu} 2>${ANSWER}
    _ch_standart_pkg=$(cat ${ANSWER})
    clear
    [[ ${_ch_standart_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_ch_standart_pkg[*]} 2>/tmp/.errlog
}
install_otherpkg()
{
    if [[ $_other_pkg_once == "0" ]]; then
        _other_pkg_once=1
        clear
        info_search_pkg
        _list_other_pkg=$(check_s_lst_pkg "${_other_pkg[*]}")
        wait
        _clist_other_pkg=$(check_q_lst_pkg "${_list_other_pkg[*]}")
        wait
        for i in ${_clist_other_pkg[*]}; do
            _other_pkg_menu="${_other_pkg_menu} ${i} - on"
        done
        clear
    fi
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_menu_extra_pkg" --checklist "$_ch_mn_bd" 0 0 16 ${_other_pkg_menu} 2>${ANSWER}
    _ch_other_pkg=$(cat ${ANSWER})
    clear
    [[ ${_ch_other_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_ch_other_pkg[*]} 2>/tmp/.errlog
}
install_pm_menu()
{
    install_pamac_aur()
    {
        cp ${_pamac_aur} /var/lib/pacman/local/
        cp ${_pamac_aur} ${MOUNTPOINT}/var/lib/pacman/local/
        pacman --root ${MOUNTPOINT} --dbpath ${MOUNTPOINT}/var/lib/pacman -U /var/lib/pacman/local/pamac-aur-7.3.3-1-x86_64.pkg.tar.xz --noconfirm
    }
    install_pamac_classic()
    {
        cp ${_pamac_classic} ${MOUNTPOINT}/var/lib/pacman/local/
        cp ${_pamac_classic} /var/lib/pacman/local/
        pacman --root ${MOUNTPOINT} --dbpath ${MOUNTPOINT}/var/lib/pacman -U /var/lib/pacman/local/pamac-classic-7.0.0-1-x86_64.pkg.tar.xz --noconfirm
    }
    install_pyt()
    {
        cp ${_package_query} ${MOUNTPOINT}/var/lib/pacman/local/
        cp ${_package_query} /var/lib/pacman/local/
        cp ${_pikaur} ${MOUNTPOINT}/var/lib/pacman/local/
        cp ${_pikaur} /var/lib/pacman/local/
        cp ${_yay} ${MOUNTPOINT}/var/lib/pacman/local/
        cp ${_yay} /var/lib/pacman/local/
        cp ${_gksu} ${MOUNTPOINT}/var/lib/pacman/local/
        cp ${_gksu} /var/lib/pacman/local/
        pacman --root ${MOUNTPOINT} --dbpath ${MOUNTPOINT}/var/lib/pacman -U /var/lib/pacman/local/package-query-1.9-3-x86_64.pkg.tar.xz --noconfirm
        pacman --root ${MOUNTPOINT} --dbpath ${MOUNTPOINT}/var/lib/pacman -U /var/lib/pacman/local/pikaur-1.4.3-1-any.pkg.tar.xz --noconfirm
        pacman --root ${MOUNTPOINT} --dbpath ${MOUNTPOINT}/var/lib/pacman -U /var/lib/pacman/local/yay-9.2.1-1-x86_64.pkg.tar.xz --noconfirm
        pacman --root ${MOUNTPOINT} --dbpath ${MOUNTPOINT}/var/lib/pacman -U /var/lib/pacman/local/gksu-2.0.2-6-x86_64.pkg.tar.xz --noconfirm
    }
    install_timeshift()
    {
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_yesno_timeshift_title" --yesno "$_yesno_timeshift_body" 0 0
        
        if [[ $? -eq 0 ]]; then
            cp ${_timeshift} ${MOUNTPOINT}/var/lib/pacman/local/
            cp ${_timeshift} /var/lib/pacman/local/
            clear
            pacman --root ${MOUNTPOINT} --dbpath ${MOUNTPOINT}/var/lib/pacman -U /var/lib/pacman/local/timeshift-19.01-2-x86_64.pkg.tar.xz --noconfirm
        fi
    }
    install_github_desktop()
    {
        dialog --defaultno --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_yesno_github_desktop_title" --yesno "$_yesno_github_desktop_body" 0 0

        if [[ $? -eq 0 ]]; then
            cp ${_github_desktop} ${MOUNTPOINT}/var/lib/pacman/local/
            cp ${_github_desktop} /var/lib/pacman/local/
            clear
            pacman --root ${MOUNTPOINT} --dbpath ${MOUNTPOINT}/var/lib/pacman -U /var/lib/pacman/local/github-desktop-2.1.0-2-x86_64.pkg.tar.xz --noconfirm
        fi
    }
    clear
    dialog --default-item 2 --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_menu_pkg_meneger" --menu "$_pm_menu_body" 0 0 2 \
    "1" $"pamac-aur" \
    "2" $"pamac-classic" 2>${ANSWER}
    case $(cat ${ANSWER}) in
    "1") install_pyt
        install_pamac_aur
        install_timeshift
        install_github_desktop
         ;;
    "2") install_pyt
        install_pamac_classic
        install_timeshift
        install_github_desktop
         ;;  
    esac
}

install_base() {
    ipv6_disable()
    {
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_yesno_ipv6_title" --yesno "$_yesno_ipv6_body" 0 0
         if [[ $? -eq 0 ]]; then
            [ -e ${MOUNTPOINT}/etc/sysctl.d/ ] || mkdir ${MOUNTPOINT}/etc/sysctl.d/
            echo "# if problem to download packets then create file:" > ${MOUNTPOINT}/etc/sysctl.d/40-ipv6.conf
            echo "# /etc/sysctl.d/40-ipv6.conf" >> ${MOUNTPOINT}/etc/sysctl.d/40-ipv6.conf
            echo "" >> ${MOUNTPOINT}/etc/sysctl.d/40-ipv6.conf
            echo "net.ipv6.conf.all.disable_ipv6=1" >> ${MOUNTPOINT}/etc/sysctl.d/40-ipv6.conf
        fi  
    }
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_InstBseTitle" \
    --menu "$_InstBseBody" 0 0 4 \
    "1" "$_InstBaseLK" \
    "2" "$_InstBaseLKBD" \
    "3" "$_InstBaseLTS" \
    "4" "$_InstBaseLTSBD" 2>${ANSWER}   

    case $(cat ${ANSWER}) in
        "1") # Latest Kernel
             clear
            info_search_pkg
            _list_base_pkg=$(check_s_lst_pkg "${_base_pkg[*]}")
            wait
            clear
            [[ ${_list_base_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} base ${_list_base_pkg[*]} 2>/tmp/.errlog \
            || pacstrap ${MOUNTPOINT} base 2>/tmp/.errlog
             ipv6_disable
             ;;
        "2") # Latest Kernel and base-devel
             clear
             info_search_pkg
            # _list_base_pkg=$(check_s_lst_pkg "${_base_pkg[*]}")
            _list_base_devel=$(check_s_lst_pkg "${_base_devel_pkg[*]}")
            wait
            clear
            [[ ${_list_base_devel[*]} != "" ]] && pacstrap ${MOUNTPOINT} base base-devel ${_list_base_devel[*]} 2>/tmp/.errlog \
            || pacstrap ${MOUNTPOINT} base base-devel 2>/tmp/.errlog
             ipv6_disable
             ;;
        "3") # LTS Kernel
             clear
             info_search_pkg
             _list_lts_pkg=$(check_s_lst_pkg "${_lts_pkg[*]}")
             wait
             _list_base_pkg=$(check_s_lst_pkg "${_base_pkg[*]}")
             wait
             clear
             [[ ${_list_lts_pkg[*]} != "" ]] && LTS=1
             [[ ${_list_lts_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} base ${_list_lts_pkg[*]} 2>/tmp/.errlog \
             || pacstrap ${MOUNTPOINT} base 2>/tmp/.errlog
             [[ ${_list_base_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_base_pkg[*]} 2>/tmp/.errlog
             #pacstrap ${MOUNTPOINT} base ${_list_lts_pkg[*]} 2>/tmp/.errlog
             # [[ $? -eq 0 ]] && LTS=1
             ipv6_disable
             ;;
        "4") # LTS Kernel and base-devel
             clear
             info_search_pkg
             _list_lts_pkg=$(check_s_lst_pkg "${_lts_pkg[*]}")
             wait
              _list_base_devel=$(check_s_lst_pkg "${_base_devel_pkg[*]}")
             wait
             clear
             [[ ${_list_lts_pkg[*]} != "" ]] && LTS=1
              [[ ${_list_lts_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} base base-devel ${_list_lts_pkg[*]} 2>/tmp/.errlog \
              || pacstrap ${MOUNTPOINT} base base-devel 2>/tmp/.errlog
              [[ ${_list_base_devel[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_base_devel[*]} 2>/tmp/.errlog
             #pacstrap ${MOUNTPOINT} base base-devel ${_list_lts_pkg[*]} 2>/tmp/.errlog
             #[[ $? -eq 0 ]] && LTS=1
             ipv6_disable
             ;;
          *) install_base_menu
             ;;
    esac    
     
    if [[ $_multilib == "1" ]]; then
        # echo "[multilib]" >>  ${MOUNTPOINT}/etc/pacman.conf
        # echo "Include = /etc/pacman.d/mirrorlist" >>  ${MOUNTPOINT}/etc/pacman.conf
	# sed -i 's/^\#\[multilib\]$/[multilib]/' ${MOUNTPOINT}/etc/pacman.conf
        # sed -i '/^\[multilib\]$/a\Include = /etc/pacman.d/mirrorlist' ${MOUNTPOINT}/etc/pacman.conf
	sed -i '93s/\#\[multilib\]/[multilib]/' ${MOUNTPOINT}/etc/pacman.conf
        sed -i '94s/\#Include/Include/' ${MOUNTPOINT}/etc/pacman.conf
    fi
    
    mirrorlist_question 
     
    # If the virtual console has been set, then copy config file to installation
   # [[ -e /tmp/vconsole.conf ]] && cp /tmp/vconsole.conf ${MOUNTPOINT}/etc/vconsole.conf 2>>/tmp/.errlog
    check_for_error

  #check for a wireless device
  if [[ $(lspci | grep -i "Network Controller") != "" ]]; then
     dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_InstWirTitle" --infobox "$_InstWirBody" 0 0 
     sleep 2
     clear
     install_wireless_programm
     clear
     check_for_error
  fi

}

# Adapted from AIS. Integrated the configuration elements.
install_bootloader() {

bios_bootloader() { 
    
   dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_InstBiosBtTitle" \
    --menu "$_InstBiosBtBody" 0 0 3 \
    "1" $"Grub2" \
    "2" $"Syslinux [MBR]" \
    "3" $"Syslinux [/]" 2>${ANSWER}
    
    clear
    
    case $(cat ${ANSWER}) in
        "1") # Grub
            clear
            info_search_pkg
            _list_grub_pkg=$(check_s_lst_pkg "${_grub_pkg[*]}")
            wait
            clear
            [[ ${_list_grub_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_grub_pkg[*]} 2>/tmp/.errlog
            check_for_error
             
             # An LVM VG/LV can consist of multiple devices. Where LVM used, user must select the device manually.
             if [[ $LVM_ROOT -eq 1 ]]; then
                select_grub_device
             else
                dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_InstGrubDevTitle" --yesno "$_InstGrubDevBody ($INST_DEV)?$_InstGrubDevBody2" 0 0
                
                if [[ $? -eq 0 ]]; then
                    clear
                    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " Grub-install " --infobox "$_PlsWaitBody" 0 0
                    sleep 1 
                    arch_chroot "grub-install --target=i386-pc --recheck ${INST_DEV}" 2>/tmp/.errlog
                    check_for_error
                else   
                    select_grub_device
                fi
             fi
                       
             arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg" 2>/tmp/.errlog
             check_for_error
             
             # if /boot is LVM then amend /boot/grub/grub.cfg accordingly
             if ( [[ $LVM_ROOT -eq 1 ]] && [[ $LVM_SEP_BOOT -eq 0 ]] ) || [[ $LVM_SEP_BOOT -eq 2 ]]; then
                sed -i '/### BEGIN \/etc\/grub.d\/00_header ###/a insmod lvm' ${MOUNTPOINT}/boot/grub/grub.cfg
             fi
         
             BOOTLOADER="Grub"
             ;;          
    "2"|"3") # Syslinux
            clear
            info_search_pkg
            _list_syslinux_pkg=$(check_s_lst_pkg "${_syslinux_pkg[*]}")
            wait
            clear
            [[ ${_list_syslinux_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_syslinux_pkg[*]} 2>/tmp/.errlog
          
             # Install to MBR or root partition, accordingly
             [[ $(cat ${ANSWER}) == "2" ]] && arch_chroot "syslinux-install_update -iam" 2>>/tmp/.errlog
             [[ $(cat ${ANSWER}) == "3" ]] && arch_chroot "syslinux-install_update -i" 2>>/tmp/.errlog
             check_for_error
             
             # Amend configuration file depending on whether lvm used or not for root.
             if [[ $LVM_ROOT -eq 0 ]]; then
                sed -i "s/sda[0-9]/${ROOT_PART}/g" ${MOUNTPOINT}/boot/syslinux/syslinux.cfg
             else
                sed -i "s/APPEND.*/APPEND root=\/dev\/mapper\/${ROOT_PART} rw/g" ${MOUNTPOINT}/boot/syslinux/syslinux.cfg
             fi
             
             # Amend configuration file for LTS kernel and/or btrfs subvolume as root
             [[ $LTS -eq 1 ]] && sed -i 's/linux/linux-lts/g' ${MOUNTPOINT}/boot/syslinux/syslinux.cfg
             [[ $BTRFS_MNT != "" ]] && sed -i "s/rw/rw $BTRFS_MNT/g" ${MOUNTPOINT}/boot/syslinux/syslinux.cfg
             
             BOOTLOADER="Syslinux"
             ;;
          *) install_base_menu
             ;;
   esac
}

uefi_bootloader() {

    #Ensure again that efivarfs is mounted
    [[ -z $(mount | grep /sys/firmware/efi/efivars) ]] && mount -t efivarfs efivarfs /sys/firmware/efi/efivars
     
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_InstUefiBtTitle" \
    --menu "$_InstUefiBtBody" 0 0 3 \
    "1" $"Grub2" \
    "2" $"rEFInd" \
    "3" $"systemd-boot" 2>${ANSWER}

     case $(cat ${ANSWER}) in
     "1") # Grub2
          clear
          info_search_pkg
          _list_grub_uefi_pkg=$(check_s_lst_pkg "${_grub_uefi_pkg[*]}")
         wait
         clear
         [[ ${_list_grub_uefi_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_grub_uefi_pkg[*]} 2>/tmp/.errlog
         check_for_error
          
          dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " Grub-install " --infobox "$_PlsWaitBody" 0 0
          sleep 1
          arch_chroot "grub-install --target=x86_64-efi --efi-directory=${UEFI_MOUNT} --bootloader-id=arch_grub --recheck" 2>/tmp/.errlog
          arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg" 2>>/tmp/.errlog
          check_for_error

          # Ask if user wishes to set Grub as the default bootloader and act accordingly
          dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_SetGrubDefTitle" --yesno "$_SetGrubDefBody ${UEFI_MOUNT}/EFI/boot $_SetGrubDefBody2" 0 0
          
          if [[ $? -eq 0 ]]; then
             arch_chroot "mkdir ${UEFI_MOUNT}/EFI/boot" 2>/tmp/.errlog
             arch_chroot "cp -r ${UEFI_MOUNT}/EFI/arch_grub/grubx64.efi ${UEFI_MOUNT}/EFI/boot/bootx64.efi" 2>>/tmp/.errlog
             check_for_error
             dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_SetDefDoneTitle" --infobox "\nGrub $_SetDefDoneBody" 0 0
             sleep 2
          fi
          
          BOOTLOADER="Grub"
          ;;
 
      "2") # rEFInd
           # Ensure that UEFI partition has been mounted to /boot/efi due to bug in script. Could "fix" it for installation, but
           # This could result in unknown consequences should the script be updated at some point.
           if [[ $UEFI_MOUNT == "/boot/efi" ]]; then      
              clear
              info_search_pkg
              _list_reefind_pkg=$(check_s_lst_pkg "${_reefind_pkg[*]}")
              wait
              clear
              [[ ${_list_reefind_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_reefind_pkg[*]} 2>/tmp/.errlog
              check_for_error   
              dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_SetRefiDefTitle" --yesno "$_SetRefiDefBody ${UEFI_MOUNT}/EFI/boot $_SetRefiDefBody2" 0 0
              
              if [[ $? -eq 0 ]]; then
                 clear
                 arch_chroot "refind-install --usedefault ${UEFI_PART} --alldrivers" 2>/tmp/.errlog
              else   
                 clear
                 arch_chroot "refind-install" 2>/tmp/.errlog
              fi   
              
              check_for_error
              
              # Now generate config file to pass kernel parameters. Default read only (ro) changed to read-write (rw),
              # and amend where using btfs subvol root       
              arch_chroot "refind-mkrlconf" 2>/tmp/.errlog
              check_for_error
              sed -i 's/ro /rw /g' ${MOUNTPOINT}/boot/refind_linux.conf
              [[ $BTRFS_MNT != "" ]] && sed -i "s/rw/rw $BTRFS_MNT/g" ${MOUNTPOINT}/boot/refind_linux.conf
              
              BOOTLOADER="rEFInd"
           else 
              dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_RefiErrTitle" --msgbox "$_RefiErrBody" 0 0
              uefi_bootloader
           fi
           ;;
         
     "3") # systemd-boot
          clear
          info_search_pkg
          _list_systemd_boot_pkg=$(check_s_lst_pkg "${_systemd_boot_pkg[*]}")
          wait
          clear
          [[ ${_list_systemd_boot_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_systemd_boot_pkg[*]} 2>/tmp/.errlog
          arch_chroot "bootctl --path=${UEFI_MOUNT} install" 2>>/tmp/.errlog
          check_for_error
          
          # Deal with LVM Root
          if [[ $LVM_ROOT -eq 0 ]]; then
             sysdb_root=$(blkid -s PARTUUID $"/dev/"${ROOT_PART} | sed 's/.*=//g' | sed 's/"//g')
          else
             sysdb_root="/dev/mapper/${ROOT_PART}" 
          fi
           
          # Deal with LTS Kernel
          if [[ $LTS -eq 1 ]]; then
            echo -e "title\tArch Linux\nlinux\t/vmlinuz-linux-lts\ninitrd\t/initramfs-linux-lts.img\noptions\troot=PARTUUID=${sysdb_root} rw" > ${MOUNTPOINT}${UEFI_MOUNT}/loader/entries/arch.conf
          else
            echo -e "title\tArch Linux\nlinux\t/vmlinuz-linux\ninitrd\t/initramfs-linux.img\noptions\troot=PARTUUID=${sysdb_root} rw" > ${MOUNTPOINT}${UEFI_MOUNT}/loader/entries/arch.conf
          fi
          
          # Fix LVM Root installations, and deal with btrfs root subvolume mounting
          [[ $LVM_ROOT -eq 1 ]] && sed -i "s/PARTUUID=//g" ${MOUNTPOINT}/boot/loader/entries/arch.conf
          [[ $BTRFS_MNT != "" ]] && sed -i "s/rw/rw $BTRFS_MNT/g" ${MOUNTPOINT}/boot/loader/entries/arch.conf
          
          BOOTLOADER="systemd-boot"
          # Set the loader file  
          echo -e "default  arch\ntimeout  5" > ${MOUNTPOINT}${UEFI_MOUNT}/loader/loader.conf 2>/tmp/.errlog
          check_for_error
          ;;
          
      *) install_base_menu
         ;;
      esac 

}

    check_mount
    # Set the default PATH variable
    arch_chroot "PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/core_perl" 2>/tmp/.errlog
    check_for_error

    if [[ $SYSTEM == "BIOS" ]]; then
       bios_bootloader
    else
       uefi_bootloader
    fi
}

# Needed for broadcom and other network controllers
install_wireless_firmware() {
    
    if [[ $_wifi_menu_form == 0 ]]; then
        _wifi_menu_form=1
        clear
        info_search_pkg
        _list_broadcom=$(check_s_lst_pkg "${_broadcom[*]}")
        wait
        _list_intel_2100=$(check_s_lst_pkg "${_intel_2100[*]}")
        wait
        _list_intel_2200=$(check_s_lst_pkg "${_intel_2200[*]}")
        wait
        [[ ${_list_broadcom[*]} != "" ]] && _list_wifi_adapter_pkg="${_list_wifi_adapter_pkg} ${_list_broadcom[*]}"
        [[ ${_list_intel_2100[*]} != "" ]] && _list_wifi_adapter_pkg="${_list_wifi_adapter_pkg} ${_list_intel_2100[*]}"
        [[ ${_list_intel_2200[*]} != "" ]] && _list_wifi_adapter_pkg="${_list_wifi_adapter_pkg} ${_list_intel_2200[*]}"
        _wifi_menu="${_menu_wifi[0]} -"
        for i in ${_list_wifi_adapter_pkg[*]}; do
            if [[ ! $i =~ .(2100) ]] && [[ ! $i =~ .(2200) ]]; then
                _wifi_menu="${_wifi_menu} ${_menu_wifi[1]} -"
            elif [[ $i =~ .(2100) ]]; then
                _wifi_menu="${_wifi_menu} ${_menu_wifi[2]} -"
            elif [[ $i =~ .(2200) ]]; then
                _wifi_menu="${_wifi_menu} ${_menu_wifi[3]} -"
            fi
        done
        _wifi_menu="${_wifi_menu} ${_menu_wifi[4]} -"
        _wifi_menu="${_wifi_menu} ${_menu_wifi[5]} -"
        clear
    fi
    
    check_mount
    
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_WirelssFirmTitle" --menu "$_WirelssFirmBody" 0 0 6 ${_wifi_menu} 2>${ANSWER}
    
    #dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_WirelssFirmTitle" --menu "$_WirelssFirmBody" 0 0 6 \
    #"1" "$_SeeWirelessDev" \
    #"2" $"Broadcom 802.11b/g/n" \
    #"3" $"Intel PRO/Wireless 2100" \
    #"4" $"Intel PRO/Wireless 2200" \
    #"5" "$_All" \
    #"6" "$_Back" 2>${ANSWER}

    case $(cat ${ANSWER}) in
    "${_menu_wifi[0]}") # Identify the Wireless Device 
        lspci -k | grep -i -A 2 "network controller" > /tmp/.wireless
        if [[ $(cat /tmp/.wireless) != "" ]]; then
           dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_WirelessShowTitle" --textbox /tmp/.wireless 0 0
        else
           dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_WirelessShowTitle" --msgbox "$_WirelessErrBody" 7 30
        fi
        ;;
    "${_menu_wifi[1]}") # Broadcom
         clear
         pacstrap ${MOUNTPOINT} ${_list_broadcom[*]} 2>/tmp/.errlog
         install_wireless_programm
        ;;
    "${_menu_wifi[2]}") # Intel 2100
         clear
         pacstrap ${MOUNTPOINT} ${_list_intel_2100[*]} 2>/tmp/.errlog
         install_wireless_programm
        ;;
    "${_menu_wifi[3]}") # Intel 2200
         clear
         pacstrap ${MOUNTPOINT} ${_list_intel_2200[*]} 2>/tmp/.errlog
         install_wireless_programm
        ;;
    "${_menu_wifi[4]}") # All
         clear
         pacstrap ${MOUNTPOINT} ${_list_wifi_adapter_pkg[*]} 2>/tmp/.errlog
         install_wireless_programm
        ;;
      *) install_base_menu
        ;;
    esac
    
    check_for_error
    install_wireless_firmware

}

# Install alsa, xorg and input drivers. Also copy the xkbmap configuration file created earlier to the installed system
# This will run only once.
install_alsa_xorg_input() {

     dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_AXITitle" --msgbox "$_AXIBody" 0 0
     clear
     info_search_pkg
     _list_x_pkg=$(check_s_lst_pkg "${_x_pkg[*]}")
     wait
     _clist_x_pkg=$(check_q_lst_pkg "${_list_x_pkg[*]}")
     wait
     clear
     [[ ${_clist_x_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_clist_x_pkg[*]} 2>/tmp/.errlog
     wait
	  pacstrap ${MOUNTPOINT} xorg 2>/tmp/.errlog
	  wait
	  sleep 5
	  wait
     arch-chroot $MOUNTPOINT /bin/bash -c "Xorg -configure" 2>>/tmp/.errlog
     wait
	  sleep 3
	  wait
     sudo cp -f ${MOUNTPOINT}/root/xorg.conf.new ${MOUNTPOINT}/etc/X11/xorg.conf
     arch_chroot "sudo cp -f /root/xorg.conf.new /etc/X11/xorg.conf" 2>>/tmp/.errlog
     wait
     sleep 3
     check_for_error
     
     # copy the keyboard configuration file, if generated
     if [[ -e /tmp/00-keyboard.conf ]]; then
        cp -f /tmp/00-keyboard.conf ${MOUNTPOINT}/etc/X11/xorg.conf.d/00-keyboard.conf
        sed -i 's/^HOOKS=(base/HOOKS=(base consolefont keymap /' ${MOUNTPOINT}/etc/mkinitcpio.conf
     fi
     # now copy across .xinitrc for all user accounts
     user_list=$(ls ${MOUNTPOINT}/home/ | sed "s/lost+found//")
     for i in ${user_list[@]}; do
         cp -f ${MOUNTPOINT}/etc/X11/xinit/xinitrc ${MOUNTPOINT}/home/$i
         arch_chroot "chown -R ${i}:users /home/${i}"
     done
     
     AXI_INSTALLED=1

}

setup_graphics_card() {

# Save repetition
install_intel(){
    clear
    info_search_pkg
    _list_intel_pkg=$(check_s_lst_pkg "${_intel_pkg[*]}")
    wait
    clear
    [[ ${_list_intel_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_intel_pkg[*]} 2>/tmp/.errlog
    sed -i 's/MODULES=""/MODULES="i915"/' ${MOUNTPOINT}/etc/mkinitcpio.conf
           
    # Intel microcode (Grub, Syslinux and systemd-boot). rEFInd is yet to be added.
    # Done as seperate if statements in case of multiple bootloaders.
    if [[ -e ${MOUNTPOINT}/boot/grub/grub.cfg ]]; then
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " grub-mkconfig " --infobox "$_PlsWaitBody" 0 0
        sleep 1
        arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg" 2>>/tmp/.errlog
    fi
               
    if [[ -e ${MOUNTPOINT}/boot/syslinux/syslinux.cfg ]]; then
        sed -i 's/..\/initramfs-linux.img/..\/intel-ucode.img,..\/initramfs-linux.img/g' ${MOUNTPOINT}/boot/syslinux/syslinux.cfg
        sed -i 's/..\/initramfs-linux-lts.img/..\/intel-ucode.img,..\/initramfs-linux-lts.img/g' ${MOUNTPOINT}/boot/syslinux/syslinux.cfg
        sed -i 's/..\/initramfs-linux-fallback.img/..\/intel-ucode.img,..\/initramfs-linux-fallback.img/g' ${MOUNTPOINT}/boot/syslinux/syslinux.cfg
        sed -i 's/..\/initramfs-linux-lts-fallback.img/..\/intel-ucode.img,..\/initramfs-linux-lts-fallback.img/g' ${MOUNTPOINT}/boot/syslinux/syslinux.cfg
    fi
               
    if [[ -e ${MOUNTPOINT}${UEFI_MOUNT}/loader/entries/arch.conf ]]; then
        sed -i '/linux \//a initrd \/intel-ucode.img' ${MOUNTPOINT}${UEFI_MOUNT}/loader/entries/arch.conf                    
    fi
}

# Save repetition
install_ati(){
    clear
    info_search_pkg
    _list_ati_pkg=$(check_s_lst_pkg "${_ati_pkg[*]}")
    wait
    clear
    [[ ${_list_ati_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_ati_pkg[*]} 2>/tmp/.errlog
    sed -i 's/MODULES=""/MODULES="radeon"/' ${MOUNTPOINT}/etc/mkinitcpio.conf
}

# Search Vedo Driver to nvidia-390xx in template 'nvidia-[0-9]{3}'
_nvidia_name=""
nvidia_search()
{
    nvsearch=$(pacman -Ss | grep -Ei "core|extra|community|multilib" | sed 's/extra\///' | sed 's/core\///' | sed 's/community\///' | sed 's/multilib\///' | grep -E "nvidia-[0-9]{3}xx" | awk '{print $1}' | awk '/^nvidia-[0-9]{3}xx$/')
    _nvidia_name=${nvsearch[*]}
}

# Main menu. Correct option for graphics card should be automatically highlighted.

    GRAPHIC_CARD=""
    INTEGRATED_GC="N/A"
    GRAPHIC_CARD=$(lspci | grep -Ei "3d|vga" | sed 's/.*://' | sed 's/(.*//' | sed 's/^[ \t]*//')
    
    # Highlight menu entry depending on GC detected. Extra work is needed for NVIDIA
    if  [[ $(echo $GRAPHIC_CARD | grep -i "nvidia") != "" ]]; then
        # If NVIDIA, first need to know the integrated GC
        [[ $(lscpu | grep -i "intel\|lenovo") != "" ]] && INTEGRATED_GC="Intel" || INTEGRATED_GC="ATI"
                
        # Second, identity the NVIDIA card and driver / menu entry
        if [[ $(dmesg | grep -i 'chipset' | grep -i 'nvc\|nvd\|nve') != "" ]]; then HIGHLIGHT_SUB_GC=7
        elif [[ $(dmesg | grep -i 'chipset' | grep -i 'nva\|nv5\|nv8\|nv9'﻿) != "" ]]; then HIGHLIGHT_SUB_GC=9
        elif [[ $(dmesg | grep -i 'chipset' | grep -i 'nv4\|nv6') != "" ]]; then HIGHLIGHT_SUB_GC=10
        else HIGHLIGHT_SUB_GC=5
        fi
    
    # All non-NVIDIA cards / virtualisation
    elif [[ $(echo $GRAPHIC_CARD | grep -i 'ati') != "" ||  $(echo $GRAPHIC_CARD | grep -i 'amd') != "" ]]; then HIGHLIGHT_SUB_GC=2
    elif [[ $(echo $GRAPHIC_CARD | grep -i 'intel\|lenovo') != "" ]]; then HIGHLIGHT_SUB_GC=3
    elif [[ $(echo $GRAPHIC_CARD | grep -i 'via') != "" ]]; then HIGHLIGHT_SUB_GC=11
    elif [[ $(echo $GRAPHIC_CARD | grep -i 'virtualbox') != "" ]]; then HIGHLIGHT_SUB_GC=12
    elif [[ $(echo $GRAPHIC_CARD | grep -i 'vmware') != "" ]]; then HIGHLIGHT_SUB_GC=13
    else HIGHLIGHT_SUB_GC=14
    fi
    
   dialog --default-item ${HIGHLIGHT_SUB_GC} --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_GCtitle" \
    --menu "$GRAPHIC_CARD\n" 0 0 11 \
    "1" "$_DevShowOpt" \
    "2" $"xf86-video-ati" \
    "3" $"xf86-video-intel" \
    "4" $"xf86-video-nouveau" \
    "5" $"xf86-video-nouveau (+ $INTEGRATED_GC)" \
    "6" $"Nvidia" \
    "7" $"Nvidia (+ $INTEGRATED_GC)" \
    "8" $"Nvidia-xxx(auto-search new-version)" \
    "9" $"Nvidia-xxx(auto-search new-version) (+ $INTEGRATED_GC)" \
    "10" $"xf86-video-openchrome" \
    "11" $"virtualbox-guest-xxx" \
    "12" $"xf86-video-vmware" \
    "13" "$_GCUnknOpt / xf86-video-fbdev" 2>${ANSWER}

   case $(cat ${ANSWER}) in
        "1") lspci -k | grep -Ei "3d|vga" > /tmp/.vga
            if [[ $(cat /tmp/.vga) != "" ]]; then
                dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_DevShowOpt" --textbox /tmp/.vga 0 0
            else
                dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_DevShowOpt" --msgbox "$_WirelessErrBody" 7 30
            fi
            ;;
        "2") # ATI/AMD
            install_ati
             ;;
        "3") # Intel
            install_intel
             ;;
        "4") # Nouveau
            clear
            info_search_pkg
            _list_nouveau=$(check_s_lst_pkg "${_nouveau[*]}")
            wait
            clear
            [[ ${_list_nouveau[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_nouveau[*]} 2>/tmp/.errlog
            sed -i 's/MODULES=""/MODULES="nouveau"/' ${MOUNTPOINT}/etc/mkinitcpio.conf       
             ;;
        "5") # Nouveau / NVIDIA
            [[ $INTEGRATED_GC == "ATI" ]] &&  install_ati || install_intel  
            clear
            info_search_pkg
            _list_nouveau=$(check_s_lst_pkg "${_nouveau[*]}")
            wait
            clear
            [[ ${_list_nouveau[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_nouveau[*]} 2>/tmp/.errlog
            sed -i 's/MODULES=""/MODULES="nouveau"/' ${MOUNTPOINT}/etc/mkinitcpio.conf       
             ;;
        "6") # NVIDIA
            arch_chroot "pacman -Rdds --noconfirm mesa"
            clear
            info_search_pkg
            [[ $LTS == 0 ]] && _list_nvidia_pkg=$(check_s_lst_pkg "${_nvidia_pkg[*]}") || _list_nvidia_lts_pkg=$(check_s_lst_pkg "${_nvidia_lts_pkg[*]}")
            wait
            clear
            # Now deal with kernel installed
            [[ $LTS == 0 ]] && pacstrap ${MOUNTPOINT} ${_list_nvidia_pkg[*]} 2>/tmp/.errlog \
            || pacstrap ${MOUNTPOINT} ${_list_nvidia_lts_pkg[*]} 2>/tmp/.errlog
            NVIDIA_INST=1
             ;;
        "7") # NVIDIA-GF
            [[ $INTEGRATED_GC == "ATI" ]] &&  install_ati || install_intel
            arch_chroot "pacman -Rdds --noconfirm mesa"
            clear
            info_search_pkg
            [[ $LTS == 0 ]] && _list_nvidia_pkg=$(check_s_lst_pkg "${_nvidia_pkg[*]}") || _list_nvidia_lts_pkg=$(check_s_lst_pkg "${_nvidia_lts_pkg[*]}")
            wait
            clear
            # Now deal with kernel installed
            [[ $LTS == 0 ]] && pacstrap ${MOUNTPOINT} ${_list_nvidia_pkg[*]} 2>/tmp/.errlog \
            || pacstrap ${MOUNTPOINT} ${_list_nvidia_lts_pkg[*]} 2>/tmp/.errlog
            NVIDIA_INST=1
             ;;
        "8") # NVIDIA-xxx
            arch_chroot "pacman -Rdds --noconfirm mesa"
            # Now deal with kernel installed
            clear
            info_search_pkg
            nvidia_search
            wait
            _nvidia_xxx=($_nvidia_name $_nvidia_name-utils $_nvidia_name-settings)
            _nvidia_lts_xxx=($_nvidia_name-lts $_nvidia_name-utils $_nvidia_name-settings)
            [[ $LTS == 0 ]] && _list_nvidia_xxx=$(check_s_lst_pkg "${_nvidia_xxx[*]}") || _list_nvidia_lts_xxx=$(check_s_lst_pkg "${_nvidia_lts_xxx[*]}")
            wait
            clear
            [[ $LTS == 0 ]] && pacstrap ${MOUNTPOINT} ${_list_nvidia_xxx[*]} 2>/tmp/.errlog \
            || pacstrap ${MOUNTPOINT} ${_list_nvidia_lts_xxx[*]} 2>/tmp/.errlog
            NVIDIA_INST=1
             ;;          
        "9") # NVIDIA-xxx
            [[ $INTEGRATED_GC == "ATI" ]] &&  install_ati || install_intel
            arch_chroot "pacman -Rdds --noconfirm mesa"
            clear
            # Now deal with kernel installed
            info_search_pkg
            nvidia_search
            wait
            _nvidia_xxx=($_nvidia_name $_nvidia_name-utils $_nvidia_name-settings)
            _nvidia_lts_xxx=($_nvidia_name-lts $_nvidia_name-utils $_nvidia_name-settings)
            [[ $LTS == 0 ]] && _list_nvidia_xxx=$(check_s_lst_pkg "${_nvidia_xxx[*]}") || _list_nvidia_lts_xxx=$(check_s_lst_pkg "${_nvidia_lts_xxx[*]}")
            wait
            clear
            [[ $LTS == 0 ]] && pacstrap ${MOUNTPOINT} ${_list_nvidia_xxx[*]} 2>/tmp/.errlog \
            || pacstrap ${MOUNTPOINT} ${_list_nvidia_lts_xxx[*]} 2>/tmp/.errlog
            NVIDIA_INST=1
             ;;            
        "10") # Via
            clear
            info_search_pkg
            _list_openchrome=$(check_s_lst_pkg "${_openchrome[*]}")
            wait
            clear
            [[ ${_list_openchrome[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_openchrome[*]} 2>/tmp/.errlog
             ;;            
        "11") # VirtualBox
            dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_VBoxInstTitle" --msgbox "$_VBoxInstBody" 0 0
            clear
            info_search_pkg
            [[ $LTS == 0 ]] && _list_vbox_pkg=$(check_s_lst_pkg "${_vbox_pkg[*]}") || _list_vbox_lts_pkg=$(check_s_lst_pkg "${_vbox_lts_pkg[*]}")
            wait
            clear
            [[ $LTS == 0 ]] && pacstrap ${MOUNTPOINT} ${_list_vbox_pkg[*]} 2>/tmp/.errlog \
            || pacstrap ${MOUNTPOINT} ${_list_vbox_lts_pkg[*]} 2>/tmp/.errlog
      
            # Load modules and enable vboxservice whatever the kernel
            arch_chroot "modprobe -a vboxguest vboxsf vboxvideo"  
            arch_chroot "systemctl enable vboxservice"
            echo -e "vboxguest\nvboxsf\nvboxvideo" > ${MOUNTPOINT}/etc/modules-load.d/virtualbox.conf
             ;;
        "12") # VMWare
            clear
            info_search_pkg
            _list_vmware_pkg=$(check_s_lst_pkg "${_vmware_pkg[*]}")
            wait
            _clist_vmware_pkg=$(check_q_lst_pkg "${_list_vmware_pkg[*]}")
            wait
            clear
            [[ ${_clist_vmware_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_clist_vmware_pkg[*]} 2>/tmp/.errlog
             ;;
        "13") # Generic / Unknown
            clear
            info_search_pkg
            _list_generic_pkg=$(check_s_lst_pkg "${_generic_pkg[*]}")
            wait
            clear
            [[ ${_list_generic_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_generic_pkg[*]} 2>/tmp/.errlog
             ;;
          *) install_desktop_menu
             ;;
    esac
    check_for_error

 # Create a basic xorg configuration file for NVIDIA proprietary drivers where installed
 # if that file does not already exist.
 if [[ $NVIDIA_INST == 1 ]] && [[ ! -e ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf ]]; then
    echo -e -n "# /etc/X11/xorg.conf.d/20-nvidia.conf\n" > ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo -e -n "Section \"Device\"\n" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo -e -n "\tIdentifier \"Nvidia Card\"\n" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo -e -n "\tDriver \"nvidia\"\n" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo -e -n "\tVendorName \"NVIDIA Corporation\"\n" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo -e -n "\tOption \"NoLogo\" \"true\"\n" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo -e -n "\t#Option \"UseEDID\" \"false\"\n" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo -e -n "\t#Option \"ConnectedMonitor\" \"DFP\"\n" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo -e -n "\t# ...\n" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
    echo -e -n "EndSection\n" >> ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
 fi
 
 # Where NVIDIA has been installed allow user to check and amend the file
 if [[ $NVIDIA_INST == 1 ]]; then
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_NvidiaConfTitle" --msgbox "$_NvidiaConfBody" 0 0
    nano ${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf
 fi

}


install_de_wm() {

   # Only show this information box once
   if [[ $SHOW_ONCE -eq 0 ]]; then
      dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_DEInfoTitle" --msgbox "$_DEInfoBody" 0 0
      SHOW_ONCE=1
   fi
   
   if [[ $_d_menu_once == "0" ]]; then
        _d_menu_once=1
        clear
        info_search_pkg
        _list_d_menu=$(check_s_lst_pkg "${_d_menu[*]}")
        wait
        clear
        for i in ${_list_d_menu[*]}; do
            case $i in
                "${_d_menu[0]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[0]}" # cinnamon
                    ;;
                "${_d_menu[1]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[1]}" # enlightenment
                    ;;
                "${_d_menu[2]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[2]}" # gnome-shell
                    ;;
                "${_d_menu[3]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[3]}" # gnome
                    ;;
                "${_d_menu[4]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[4]}" # gnome-extra
                    ;;
                "${_d_menu[5]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[5]}" # plasma-desktop
                    ;;
                "${_d_menu[6]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[6]}" # plasma
                    ;;
                "${_d_menu[7]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[7]}" # lxde
                    ;;
                "${_d_menu[8]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[8]}" # lxqt
                    ;;
                "${_d_menu[9]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[9]}" # mate
                    ;;
                "${_d_menu[10]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[10]}" # mate-extra
                    ;;
                "${_d_menu[11]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[11]}" # xfce4
                    ;;
                "${_d_menu[12]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[12]}" # xfce4-goodies
                    ;;
                "${_d_menu[13]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[13]}" # awesome
                    ;;
                "${_d_menu[14]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[14]}" # fluxbox
                    ;;
                "${_d_menu[15]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[15]}" # i3-wm
                    ;;
                "${_d_menu[16]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[16]}" # icewm
                    ;;
                "${_d_menu[17]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[17]}" # openbox
                    ;;
                "${_d_menu[18]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[18]}" # pekwm
                    ;;
                "${_d_menu[19]}") _dm_desktop_menu="${_dm_desktop_menu} ${_desktop_menu[19]}" # windowmaker
                    ;;
            esac
        done
        _list_dm_menu=""
        for i in ${_dm_desktop_menu[*]}; do
            _list_dm_menu="${_list_dm_menu} $i -"
        done
    fi
   
   dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_InstDETitle" --menu "$_InstDEBody" 0 0 16 ${_list_dm_menu} 2>${ANSWER}
   
    #dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_InstDETitle" \
    #--menu "$_InstDEBody" 0 0 11 \
    #"1" $"Cinnamon" \
    #"2" $"Enlightenment" \
    #"3" $"Gnome-Shell (minimal)" \
    #"4" $"Gnome" \
    #"5" $"Gnome + Extras" \
    #"6" $"KDE 5 Base (minimal)" \
    #"7" $"KDE 5" \
    #"8" $"LXDE" \
    #"9" $"LXQT" \
    #"10" $"MATE" \
    #"11" $"MATE + Extras" \
    #"12" $"Xfce" \
    #"13" $"Xfce + Extras" \
    #"14" $"Awesome WM" \
    #"15" $"Fluxbox WM" \
    #"16" $"i3 WM" \
    #"17" $"Ice WM" \
    #"18" $"Openbox WM" \
    #"19" $"Pek WM" \
    #"20" $"WindowMaker WM" 2>${ANSWER}

   case $(cat ${ANSWER}) in
        "${_desktop_menu[0]}") # Cinnamon
             clear
             info_search_pkg
            _list_cinnamon_pkg=$(check_s_lst_pkg "${_cinnamon_pkg[*]}")
            wait
            clear
            [[ ${_list_cinnamon_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_cinnamon_pkg[*]} 2>/tmp/.errlog
             ;;
        "${_desktop_menu[1]}") # Enlightement
             clear
             info_search_pkg
            _list_enlightenment_pkg=$(check_s_lst_pkg "${_enlightenment_pkg[*]}")
            wait
            clear
            [[ ${_list_enlightenment_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_enlightenment_pkg[*]} 2>/tmp/.errlog
             ;;
        "${_desktop_menu[2]}") # Gnome-Shell
             clear
             info_search_pkg
             _list_gnome_shell_pkg=$(check_s_lst_pkg "${_gnome_shell_pkg[*]}")
             wait
             clear
             [[ ${_list_gnome_shell_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_gnome_shell_pkg[*]} 2>/tmp/.errlog
             GNOME_INSTALLED=1
             ;;
        "${_desktop_menu[3]}") # Gnome
             clear
             info_search_pkg
            _list_gnome_pkg=$(check_s_lst_pkg "${_gnome_pkg[*]}")
            wait
            clear
            [[ ${_list_gnome_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_gnome_pkg[*]} 2>/tmp/.errlog
           
             GNOME_INSTALLED=1
             ;;            
        "${_desktop_menu[4]}") # Gnome + Extras
             clear
             info_search_pkg
            _list_gnome_extras_pkg=$(check_s_lst_pkg "${_gnome_extras_pkg[*]}")
            wait
            clear
            [[ ${_list_gnome_extras_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_gnome_extras_pkg[*]} 2>/tmp/.errlog
           
             GNOME_INSTALLED=1
             ;;
        "${_desktop_menu[5]}") # KDE5 BASE
             clear
            info_search_pkg
            _list_kde5base_pkg=$(check_s_lst_pkg "${_kde5base_pkg[*]}")
            wait
            clear
            [[ ${_list_kde5base_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_kde5base_pkg[*]} 2>/tmp/.errlog
             ;;
        "${_desktop_menu[6]}") # KDE5 
             clear
             info_search_pkg
            _list_kde_pkg=$(check_s_lst_pkg "${_kde_pkg[*]}")
            wait
            clear
            [[ ${_list_kde_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_kde_pkg[*]} 2>/tmp/.errlog

             if [[ $NM_INSTALLED -eq 0 ]]; then          
                arch_chroot "systemctl enable NetworkManager.service && systemctl enable NetworkManager-dispatcher.service" 2>>/tmp/.errlog
                NM_INSTALLED=1
             fi
               
             KDE_INSTALLED=1
             ;;
         "${_desktop_menu[7]}") # LXDE
              clear
              info_search_pkg
              _list_lxde_pkg=$(check_s_lst_pkg "${_lxde_pkg[*]}")
              wait
              clear
              [[ ${_list_lxde_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_lxde_pkg[*]} 2>/tmp/.errlog
              LXDE_INSTALLED=1
             ;;
         "${_desktop_menu[8]}") # LXQT
              clear
              info_search_pkg
            _list_lxqt_pkg=$(check_s_lst_pkg "${_lxqt_pkg[*]}")
            wait
            clear
            [[ ${_list_lxqt_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_lxqt_pkg[*]} 2>/tmp/.errlog
              LXQT_INSTALLED=1
              ;;
         "${_desktop_menu[9]}") # MATE
              clear
              info_search_pkg
            _list_mate_pkg=$(check_s_lst_pkg "${_mate_pkg[*]}")
            wait
            clear
            [[ ${_list_mate_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_mate_pkg[*]} 2>/tmp/.errlog
             ;;
        "${_desktop_menu[10]}") # MATE + Extras
               clear
              info_search_pkg
            _list_mateextra_pkg=$(check_s_lst_pkg "${_mateextra_pkg[*]}")
            wait
            [[ ${_list_mateextra_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_mateextra_pkg[*]} 2>/tmp/.errlog
             ;;                 
        "${_desktop_menu[11]}") # Xfce
              clear
              info_search_pkg
            _list_xfce4_pkg=$(check_s_lst_pkg "${_xfce4_pkg[*]}")
            wait
            clear
            [[ ${_list_xfce4_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_xfce4_pkg[*]} 2>/tmp/.errlog
             ;;            
        "${_desktop_menu[12]}") # Xfce + Extras
              clear
              info_search_pkg
            _list_xfce4_extra_pkg=$(check_s_lst_pkg "${_xfce4_extra_pkg[*]}")
            wait
            clear
            [[ ${_list_xfce4_extra_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_xfce4_extra_pkg[*]} 2>/tmp/.errlog
             ;;
        "${_desktop_menu[13]}") # Awesome
              clear
              info_search_pkg
            _list_awesome_pkg=$(check_s_lst_pkg "${_awesome_pkg[*]}")
            wait
            clear
            [[ ${_list_awesome_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_awesome_pkg[*]} 2>/tmp/.errlog
             ;;
        "${_desktop_menu[14]}") #Fluxbox
              clear
              info_search_pkg
            _list_fluxbox_pkg=$(check_s_lst_pkg "${_fluxbox_pkg[*]}")
            wait
            clear
            [[ ${_list_fluxbox_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_fluxbox_pkg[*]} 2>/tmp/.errlog
             ;; 
        "${_desktop_menu[15]}") #i3
              clear
              info_search_pkg
            _list_i3wm_pkg=$(check_s_lst_pkg "${_i3wm_pkg[*]}")
            wait
            clear
            [[ ${_list_i3wm_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_i3wm_pkg[*]} 2>/tmp/.errlog
             ;; 
        "${_desktop_menu[16]}") #IceWM
              clear
              info_search_pkg
            _list_icewm_pkg=$(check_s_lst_pkg "${_icewm_pkg[*]}")
            wait
            clear
            [[ ${_list_icewm_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_icewm_pkg[*]} 2>/tmp/.errlog
             ;; 
        "${_desktop_menu[17]}") #Openbox
              clear
              info_search_pkg
            _list_openbox_pkg=$(check_s_lst_pkg "${_openbox_pkg[*]}")
            wait
            clear
            [[ ${_list_openbox_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_openbox_pkg[*]} 2>/tmp/.errlog
             ;; 
        "${_desktop_menu[18]}") #PekWM
              clear
              info_search_pkg
            _list_pekwm_pkg=$(check_s_lst_pkg "${_pekwm_pkg[*]}")
            wait
            clear
            [[ ${_list_pekwm_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_pekwm_pkg[*]} 2>/tmp/.errlog
             ;;
        "${_desktop_menu[19]}") #WindowMaker
             clear
             info_search_pkg
            _list_windowmaker_pkg=$(check_s_lst_pkg "${_windowmaker_pkg[*]}")
            wait
            clear
            [[ ${_list_windowmaker_pkg[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_windowmaker_pkg[*]} 2>/tmp/.errlog
             ;;        
          *) install_desktop_menu
             ;;
    esac  
    
    check_for_error
}

# Determine if LXDE, LXQT, Gnome, and/or KDE has been installed, and act accordingly.
install_dm() {

# Function to save repetition
dm_menu(){

    #if [[ _dm_menu_once == 0 ]]; then
    #   _dm_menu_once=1
    #   clear
    #   info_search_pkg
    #   _list_dm_menu=$(check_s_lst_pkg "${_user_dm_menu[*]}")
    #   wait
    #   clear
    #   _listdm_menu=""
    #   for i in ${_list_dm_menu[*]}; do
    #       _listdm_menu="${_listdm_menu} $i -"
    #   done
    #fi
    
#   dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_DmChTitle" --menu "$_DmChBody" 0 0 5 ${_listdm_menu} 2>${ANSWER}
  dialog --default-item 3 --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_DmChTitle" \
               --menu "$_DmChBody" 0 0 4 \
               "1" $"LXDM" \
               "2" $"LightDM" \
               "3" $"SDDM" \
               "4" $"SLiM" 2>${ANSWER}  
    
              case $(cat ${ANSWER}) in
              "1") # LXDM
                   clear
                   info_search_pkg
                    _list_lxdm_pkg=$(check_s_lst_pkg "${_lxdm_pkg[*]}")
                    wait
                    clear
                   pacstrap ${MOUNTPOINT} ${_list_lxdm_pkg[*]} 2>/tmp/.errlog
                   arch_chroot "systemctl enable lxdm.service" >/dev/null 2>>/tmp/.errlog
                   DM="LXDM"
                   ;;
              "2") # LIGHTDM
                   clear
                   info_search_pkg
                    _list_lightdm_pkg=$(check_s_lst_pkg "${_lightdm_pkg[*]}")
                    wait
                    clear
                   pacstrap ${MOUNTPOINT} ${_list_lightdm_pkg[*]} 2>/tmp/.errlog
                   arch_chroot "systemctl enable lightdm.service" >/dev/null 2>>/tmp/.errlog
                   DM="LightDM"
                   ;;
              "3") # SDDM
                   clear
                   info_search_pkg
                    _list_sddm_pkg=$(check_s_lst_pkg "${_sddm_pkg[*]}")
                    wait
                    clear
                   pacstrap ${MOUNTPOINT} ${_list_sddm_pkg[*]} 2>/tmp/.errlog
                   arch_chroot "sddm --example-config > /etc/sddm.conf"
                   arch_chroot "systemctl enable sddm.service" >/dev/null 2>>/tmp/.errlog
                   DM="SDDM"
                   ;;
             # "4") # GDM
            #       clear
            #       info_search_pkg
            #       _list_gdm_pkg=$(check_s_lst_pkg "${_gdm_pkg[*]}")
            #       wait
            #       clear
             #      pacstrap ${MOUNTPOINT} ${_list_gdm_pkg[*]} 2>/tmp/.errlog
             #      # arch_chroot "gdm --example-config > /etc/gdm.conf"
             #      arch_chroot "systemctl enable gdm.service" >/dev/null 2>>/tmp/.errlog
             #      DM="GDM"
            #       ;;
              "4") # SLiM
                   clear
                   info_search_pkg
                    _list_slim_pkg=$(check_s_lst_pkg "${_slim_pkg[*]}")
                    wait
                    clear
                   pacstrap ${MOUNTPOINT} ${_list_slim_pkg[*]} 2>/tmp/.errlog
                   arch_chroot "systemctl enable slim.service" >/dev/null 2>>/tmp/.errlog
                   DM="SLiM"

                   # Amend the xinitrc file accordingly for all user accounts
                   user_list=$(ls ${MOUNTPOINT}/home/ | sed "s/lost+found//")
                   for i in ${user_list[@]}; do
                       if [[ -n ${MOUNTPOINT}/home/$i/.xinitrc ]]; then
                          cp -f ${MOUNTPOINT}/etc/X11/xinit/xinitrc ${MOUNTPOINT}/home/$i/.xinitrc
                          arch_chroot "chown -R ${i}:users /home/${i}"
                       fi
                       echo 'exec $1' >> ${MOUNTPOINT}/home/$i/.xinitrc
                   done    
                   ;;                
                *) install_desktop_menu
                   ;;
            esac
}

 if [[ $DM_INSTALLED -eq 0 ]]; then
         # Gnome without KDE
         if [[ $GNOME_INSTALLED -eq 1 ]] && [[ $KDE_INSTALLED -eq 0 ]]; then
            arch_chroot "systemctl enable gdm.service" >/dev/null 2>/tmp/.errlog
            DM="GDM"

         # Gnome with KDE
         elif [[ $GNOME_INSTALLED -eq 1 ]] && [[ $KDE_INSTALLED -eq 1 ]]; then   
             dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_DmChTitle" \
               --menu "$_DmChBody" 12 45 2 \
               "1" $"GDM  (Gnome)" \
               "2" $"SDDM (KDE)" 2>${ANSWER}    
    
              case $(cat ${ANSWER}) in
              "1") arch_chroot "systemctl enable gdm.service" >/dev/null 2>/tmp/.errlog
                   DM="GDM"
                   ;;
              "2") arch_chroot "sddm --example-config > /etc/sddm.conf"
                   arch_chroot "systemctl enable sddm.service" >/dev/null 2>>/tmp/.errlog
                   DM="SDDM"
                   ;;
                *) install_desktop_menu
                ;;
              esac    
              
         # KDE without Gnome      
        elif [[ $KDE_INSTALLED -eq 1 ]] && [[ $GNOME_INSTALLED -eq 0 ]]; then
            arch_chroot "sddm --example-config > /etc/sddm.conf"
            arch_chroot "systemctl enable sddm.service" >/dev/null 2>>/tmp/.errlog
            DM="SDDM"
            
         # LXDM, without KDE or Gnome 
         elif [[ $LXDE_INSTALLED -eq 1 ]] && [[ $KDE_INSTALLED -eq 0 ]] && [[ $GNOME_INSTALLED -eq 0 ]]; then
            arch_chroot "systemctl enable lxdm.service" >/dev/null 2>/tmp/.errlog
            DM="LXDM"

         # Otherwise, select a DM      
         else 
           dm_menu      
         fi
        
        # Check installation success, inform user, and flag DM_INSTALLED so it cannot be run again
        check_for_error
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " $DM $_DmDoneTitle" --msgbox "\n$DM $_DMDoneBody" 0 0
        DM_INSTALLED=1
         
  # if A display manager has already been installed and enabled (DM_INSTALLED=1), show a message instead.
  else  
         dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_DmInstTitle" --msgbox "$_DmInstBody" 0 0
  fi       

}

# General Menu Package

# back - install_desktop_menu
install_gep()
{
    if [[ $SUB_MENU != "general_package" ]]; then
       SUB_MENU="general_package"
       HIGHLIGHT_SUB=1
    else
       if [[ $HIGHLIGHT_SUB != 7 ]]; then
          HIGHLIGHT_SUB=$(( HIGHLIGHT_SUB + 1 ))
       fi
    fi
    
    dialog --default-item ${HIGHLIGHT_SUB} --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_menu_gen_title" --menu "$_menu_gen_body" 0 0 7 \
    "1" "$_menu_gengen" \
    "2" "$_menu_archivers" \
    "3" "$_menu_ttf_theme" \
    "4" "$_menu_add_pkg" \
    "5" "$_menu_extra_pkg" \
    "6" "$_menu_pkg_meneger" \
    "7" "$_Back" 2>${ANSWER}
    
    HIGHLIGHT_SUB=$(cat ${ANSWER})
    case $(cat ${ANSWER}) in
    "1") install_gengen
         ;;
    "2") install_archivers
         ;;
    "3") install_ttftheme
         ;;
    "4") install_standartpkg
         ;;
    "5") install_otherpkg
         ;;
    "6") install_pm_menu
         ;;
      *) # Back to NAME Menu
        install_desktop_menu
         ;;
    esac
    
    check_for_error
    
    install_gep
}

install_shara_components()
{
    if [[ $_shara_p == "0" ]]; then
        dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_yesno_shara_title" --yesno "$_yesno_shara_body" 0 0
        if [[ $? -eq 0 ]]; then
            _shara_p=1
            clear
            info_search_pkg
            _list_network_pkg=$(check_s_lst_pkg "${_network_pkg[*]}")
            wait
            _clist_list_network_pkg=$(check_q_lst_pkg "${_list_network_pkg[*]}")
            wait
            clear
            pacstrap ${MOUNTPOINT} ${_clist_list_network_pkg[*]} 2>/tmp/.errlog
        fi
    fi
}

install_nm() {
   # Check to see if a NM has already been installed and enabled
   if [[ $NM_INSTALLED -eq 0 ]]; then
        if [[ $_nm_once == 0 ]]; then
            _nm_once=1
            clear
            info_search_pkg
            _list_network_menu=$(check_s_lst_pkg "${_network_menu[*]}")
            wait
            clear
            _ln_menu=""
            for i in ${_list_network_menu[*]}; do
                _ln_menu="${_ln_menu} $i -"
            done
            _ln_menu="${_ln_menu} dhcpcd -"
        fi
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_InstNMTitle" --menu "$_InstNMBody" 0 0 4 ${_ln_menu} 2>${ANSWER}
      #dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_InstNMTitle" \
      #--menu "$_InstNMBody" 0 0 4 \
      #"1" $"Connman (CLI)" \
      #"2" $"dhcpcd  (CLI)" \
      #"3" $"Network Manager (GUI)" \
      #"4" $"WICD (GUI)" 2>${ANSWER}    
    
      case $(cat ${ANSWER}) in
      "connman") # connman
           clear
            info_search_pkg
            _list_connman_pkg=$(check_s_lst_pkg "${_connman_pkg[*]}")
            wait
            clear
           pacstrap ${MOUNTPOINT} ${_list_connman_pkg[*]} 2>/tmp/.errlog
           install_shara_components
           arch_chroot "systemctl enable connman.service" 2>>/tmp/.errlog
           ;;
      "dhcpcd") # dhcpcd
           clear
           install_shara_components
           arch_chroot "systemctl enable dhcpcd.service" 2>/tmp/.errlog
           ;;
      "networkmanager") # Network Manager
           clear
           info_search_pkg
            _list_net=$(check_s_lst_pkg "${_networkmanager_pkg[*]}")
            wait
            _clist_list_net=$(check_q_lst_pkg "${_list_net[*]}")
            wait
            _list_net_connect=$(check_s_lst_pkg "${_net_connect_var[*]}")
            wait
            _clist_list_net_conn=$(check_q_lst_pkg "${_list_net_connect[*]}")
            wait
            clear
            [[ ${_clist_list_net[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_clist_list_net[*]} 2>/tmp/.errlog
            [[ ${_clist_list_net_conn[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_clist_list_net_conn[*]} 2>/tmp/.errlog
           install_shara_components
           arch_chroot "systemctl enable NetworkManager.service && systemctl enable NetworkManager-dispatcher.service" 2>>/tmp/.errlog
           ;;
      "wicd-gtk") # WICD
           clear
            info_search_pkg
            _list_wicd_pkg=$(check_s_lst_pkg "${_wicd_pkg[*]}")
            wait
            clear
           pacstrap ${MOUNTPOINT} ${_list_wicd_pkg[*]} 2>/tmp/.errlog
           install_shara_components
           arch_chroot "systemctl enable wicd.service" 2>>/tmp/.errlog
           ;;
        *) install_desktop_menu
           ;;
      esac
      
      check_for_error
      dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_InstNMDoneTitle" --msgbox "$_InstNMDoneBody" 0 0
      NM_INSTALLED=1
   
   else
      dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_InstNMDoneTitle" --msgbox "$_InstNMErrBody" 0 0
   fi
}


test() {
    
    ping -c 3 google.com > /tmp/.outfile &
    dialog --title "checking" --no-kill --tailboxbg /tmp/.outfile 20 60 

}
