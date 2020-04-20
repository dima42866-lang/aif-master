#!/bin/bash
#
setup_graphics_card() {

# Save repetition
install_intel(){
    clear
    info_search_pkg
    _list_intel_pkg=$(check_s_lst_pkg "${_intel_pkg[*]}")
    wait
    clear
    [[ ${_list_intel_pkg[*]} != "" ]] && ps_in_pkg "${_list_intel_pkg[*]}"
    
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

# Main menu. Correct option for graphics card should be automatically highlighted.

    GRAPHIC_CARD=""
    INTEGRATED_GC="N/A"
    GRAPHIC_CARD=$(lspci | grep -Ei "3d|vga" | sed 's/.*://' | sed 's/(.*//' | sed 's/^[ \t]*//')
    GRAPHIC_CARD_Integrated=$(lscpu | grep -Ei "intel|lenovo" | sed 's/.*://' | sed 's/(.*//' | sed 's/^[ \t]*//' | grep -vi "genuine")
    # Highlight menu entry depending on GC detected. Extra work is needed for NVIDIA
    if  [[ $(echo "$GRAPHIC_CARD" | grep -Ei "nvidia" | awk '/NVIDIA/' RS=" ") != "" ]]; then 
        HIGHLIGHT_SUB_GC=8
        # If NVIDIA, first need to know the integrated GC
        [[ $(echo "$GRAPHIC_CARD_Integrated") != "" ]] && INTEGRATED_GC="Intel" || INTEGRATED_GC="ATI"
      
    # All non-NVIDIA cards / virtualisation
    elif [[ $(echo "$GRAPHIC_CARD" | grep -Ei 'ati|amd' | awk '/ATI|AMD/' RS=" ") != "" ]]; then HIGHLIGHT_SUB_GC=2
    elif [[ $(echo "$GRAPHIC_CARD" | grep -Ei 'intel|lenovo' | awk '/Intel|Lenovo/' RS=" ") != "" ]]; then HIGHLIGHT_SUB_GC=3
    elif [[ $(echo "$GRAPHIC_CARD" | grep -Ei 'via' | awk '/VIA/' RS=" ") != "" ]]; then HIGHLIGHT_SUB_GC=18
    elif [[ $(echo "$GRAPHIC_CARD" | grep -Ei 'virtualbox' | awk '/VirtualBox/' RS=" ") != "" ]]; then HIGHLIGHT_SUB_GC=19
    elif [[ $(echo "$GRAPHIC_CARD" | grep -Ei 'vmware' | awk '/VMware/' RS=" ") != "" ]]; then HIGHLIGHT_SUB_GC=20
    else HIGHLIGHT_SUB_GC=21
    fi
    
    skip_orderers_resume
    
   dialog --default-item ${HIGHLIGHT_SUB_GC} --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_GCtitle" \
    --menu "$GRAPHIC_CARD\n" 0 0 16 \
    "1" "$_DevShowOpt" \
    "2" $"xf86-video-ati" \
    "3" $"xf86-video-intel" \
    "4" $"xf86-video-nouveau" \
    "5" $"xf86-video-nouveau (+ $INTEGRATED_GC)" \
    "6" $"Nvidia" \
    "7" $"Nvidia (+ $INTEGRATED_GC)" \
    "8" $"Nvidia-dkms" \
    "9" $"Nvidia-dkms (+ $INTEGRATED_GC)" \
    "10" $"Nvidia-340xx" \
    "11" $"Nvidia-340xx (+ $INTEGRATED_GC)" \
    "12" $"Nvidia-340xx-dkms" \
    "13" $"Nvidia-340xx-dkms (+ $INTEGRATED_GC)" \
    "14" $"Nvidia-390xx" \
    "15" $"Nvidia-390xx (+ $INTEGRATED_GC)" \
    "16" $"Nvidia-390xx-dkms" \
    "17" $"Nvidia-390xx-dkms (+ $INTEGRATED_GC)" \
    "18" $"xf86-video-openchrome" \
    "19" $"virtualbox-guest-xxx" \
    "20" $"xf86-video-vmware" \
    "21" "$_GCUnknOpt / xf86-video-fbdev" 2>${ANSWER}

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
        "6") 
             ;;
        "7") 
             ;;
        "8") 
             ;;          
        "9") 
             ;;
        "10") 
             ;;
        "11") 
             ;;
        "12") 
             ;;
        "13") 
             ;;
        "14") 
             ;;
        "15") 
             ;;
        "16") 
             ;;
        "17") 
             ;;                                       
        "18") # Via
            clear
            info_search_pkg
            _list_openchrome=$(check_s_lst_pkg "${_openchrome[*]}")
            wait
            clear
            [[ ${_list_openchrome[*]} != "" ]] && pacstrap ${MOUNTPOINT} ${_list_openchrome[*]} 2>/tmp/.errlog
             ;;            
        "19") # VirtualBox
            dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_VBoxInstTitle" --msgbox "$_VBoxInstBody" 0 0
            clear
            info_search_pkg
            [[ $LTS == 0 ]] && _list_vbox_pkg=$(check_s_lst_pkg "${_vbox_pkg[*]}") || _list_vbox_lts_pkg=$(check_s_lst_pkg "${_vbox_lts_pkg[*]}")
            wait
            clear
            [[ $LTS == 0 ]] && ps_in_pkg "${_list_vbox_pkg[*]}" \
            || pacstrap ${MOUNTPOINT} ${_list_vbox_lts_pkg[*]} 2>/tmp/.errlog
      
            # Load modules and enable vboxservice whatever the kernel
            arch_chroot "modprobe -a vboxguest vboxsf vboxvideo"  
            arch_chroot "systemctl enable vboxservice"
            echo -e "vboxguest\nvboxsf\nvboxvideo" > ${MOUNTPOINT}/etc/modules-load.d/virtualbox.conf
             ;;
        "20") # VMWare
            clear
            info_search_pkg
            _list_vmware_pkg=$(check_s_lst_pkg "${_vmware_pkg[*]}")
            wait
            _clist_vmware_pkg=$(check_q_lst_pkg "${_list_vmware_pkg[*]}")
            wait
            clear
            [[ ${_clist_vmware_pkg[*]} != "" ]] && ps_in_pkg "${_clist_vmware_pkg[*]}"
             ;;
        "21") # Generic / Unknown
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
 if [[ $NVIDIA_INST == 1 ]] && [[ ! -e "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf" ]]; then
    echo -e -n "# /etc/X11/xorg.conf.d/20-nvidia.conf\n" > "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf"
    echo -e -n "Section \"Device\"\n" >> "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf"
    echo -e -n "\tIdentifier \"Nvidia Card\"\n" >> "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf"
    echo -e -n "\tDriver \"nvidia\"\n" >> "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf"
    echo -e -n "\tVendorName \"NVIDIA Corporation\"\n" >> "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf"
    echo -e -n "\tOption \"NoLogo\" \"true\"\n" >> "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf"
    echo -e -n "\t#Option \"UseEDID\" \"false\"\n" >> "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf"
    echo -e -n "\t#Option \"ConnectedMonitor\" \"DFP\"\n" >> "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf"
    echo -e -n "\t# ...\n" >> "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf"
    echo -e -n "EndSection\n" >> "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf"
 fi
 
 # Where NVIDIA has been installed allow user to check and amend the file
 if [[ $NVIDIA_INST == 1 ]]; then
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_NvidiaConfTitle" --msgbox "$_NvidiaConfBody" 0 0
    nano "${MOUNTPOINT}/etc/X11/xorg.conf.d/20-nvidia.conf"
 fi

}
#
function xorg_modif()
{
	if [ -e "${MOUNTPOINT}/etc/X11/xorg.conf" ]; then
		sed -Ei '/Section \"Module\"/a\ \tLoad \"modesetting\"' ${MOUNTPOINT}/etc/X11/xorg.conf
		sed -Ei '/Section \"Module\"/a\ \tLoad \"freetype\"' ${MOUNTPOINT}/etc/X11/xorg.conf
		sed -Ei '/Section \"Module\"/a\ \tLoad \"type1\"' ${MOUNTPOINT}/etc/X11/xorg.conf
		sed -Ei '/Section \"Module\"/a\ \tLoad \"dbe\"' ${MOUNTPOINT}/etc/X11/xorg.conf
		sed -Ei '/Section \"Module\"/a\ \tLoad \"extmod\"' ${MOUNTPOINT}/etc/X11/xorg.conf
		sed -Ei '/Driver/s/intel/modesetting/' ${MOUNTPOINT}/etc/X11/xorg.conf
	fi
}
