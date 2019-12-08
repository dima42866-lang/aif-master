#!/bin/bash
#
vrf_cnt_fls()
{
    gt_cln_all()
    {
        mkdir -p "$_aif_temp_folder"
        git clone "$aif_master_git" "$_aif_temp_folder"
        wait
    }
    gt_cln_eml()
    {
        [[ -e "$_aif_temp_folder" ]] || gt_cln_all
        wait
        mkdir -p "$_eml_folder"
        cp -Rfa "$_aif_temp_eml_dir"/* "$_eml_folder"
        wait
    }
    gt_cln_pm()
    {
        [[ -e "$_aif_temp_folder" ]] || gt_cln_all
        wait
        mkdir -p "$_pkg_manager_folder"
        cp -Rfa "$_aif_temp_pm_dir"/* "$_pkg_manager_folder"
        wait
    }
    gt_cln_aur()
    {
        [[ -e "$_aif_temp_folder" ]] || gt_cln_all
        wait
        find "$_aif_temp_aur_dir" -maxdepth 1 -type f -exec cp -f {} "$_aur_pkg_folder"/ \;
        wait
    }
    echo -e -n "\n\e[1;37mПроверка наличия обязательных директорий и файлов.\e[0m\n"
    echo -e -n "\e[1;37mCheck the availability of the required file and directories.\e[0m\n"
    if [[ -e "$_aur_pkg_folder" ]]; then
        echo -e -n "\n\e[1;32m$_aur_pkg_folder/\n\e[1;37mОбязатеьная директория присутствует.\e[0m"
        outin_success
        echo -e -n "\n\e[1;32m$_aur_pkg_folder/\n\e[1;37mThe required directory is exists.\e[0m"
        outin_success
        echo ""
        _temp=$(find "$_aur_pkg_folder" -maxdepth 1 -type f | grep -Eiv "windowsfonts" | wc -l)
        if [ $_temp  -le 1 ]; then
            echo -e -n "\n\e[1;31m$_aur_pkg_folder\n\e[1;37mВ директории менее 2 файлов.\nЭто может нарушить работу программы.\e[1;0m"
            outin_failure
            echo -e -n "\n\e[1;31m$_aur_pkg_folder\n\e[1;37mThere are less than 2 files in the directory.\nIt may interfere with the operation of the program.\e[1;0m"
            outin_failure
            echo -e -n "\n\e[1;37mНедостающие пакеты будут загружены из удаленного репозитория.\e[0m"
            echo -e -n "\n\e[1;37mThe missing packages will be downloaded from the remote repository.\e[0m\n"
            echo ""
            gt_cln_aur
        fi
        if [[ -e "$_eml_folder" ]]; then
            _temp=$(find "$_eml_folder" -maxdepth 1 -type f | wc -l)
            if [ $_temp  -le 1 ]; then
                echo -e -n "\n\e[1;31m$_eml_folder\n\e[1;37mВ директории менее 2 файлов.\nЭто может нарушить работу программы.\e[1;0m"
                outin_failure
                echo -e -n "\n\e[1;31m$_eml_folder\n\e[1;37mThere are less than 2 files in the directory.\nIt may interfere with the operation of the program.\e[1;0m"
                outin_failure
                echo -e -n "\n\e[1;37mНедостающие пакеты будут загружены из удаленного репозитория.\e[0m"
                echo -e -n "\n\e[1;37mThe missing packages will be downloaded from the remote repository.\e[0m\n"
                echo ""
                gt_cln_eml
            fi
        else
            echo -e -n "\n\e[1;31m$_eml_folder\n\e[1;37mДиректория отсутствует.\e[0m"
            outin_failure
            echo -e -n "\n\e[1;31m$_eml_folder\n\e[1;37mDirectory is not found.\e[0m"
            outin_failure
            echo -e -n "\n\e[1;37mНедостающие пакеты будут загружены из удаленного репозитория.\e[0m"
            echo -e -n "\n\e[1;37mThe missing packages will be downloaded from the remote repository.\e[0m\n"
            echo ""
            gt_cln_eml
        fi
        if [[ -e "$_pkg_manager_folder" ]]; then
            _temp=$(find "$_pkg_manager_folder" -maxdepth 1 -type f | wc -l)
            if [ $_temp  -le 2 ]; then
                echo -e -n "\n\e[1;31m$_pkg_manager_folder\n\e[1;37mВ директории менее 3 файлов.\nЭто может нарушить работу программы.\e[1;0m"
                outin_failure
                echo -e -n "\n\e[1;31m$_pkg_manager_folder\n\e[1;37mThere are less than 3 files in the directory.\nIt may interfere with the operation of the program.\e[1;0m"
                outin_failure
                echo -e -n "\n\e[1;37mНедостающие пакеты будут загружены из удаленного репозитория.\e[0m"
                echo -e -n "\n\e[1;37mThe missing packages will be downloaded from the remote repository.\e[0m\n"
                echo ""
                gt_cln_pm
            fi
            _temp=$(find "$_pkg_manager_folder" -maxdepth 1 -type f -iname "pamac*" | rev | cut -d '/' -f1 | rev | wc -l)
            if [ $_temp -le 1 ]; then
                echo -e -n "\n\e[1;31m$_pkg_manager_folder\n\e[1;37mВ директории должны присутствовать 2 пакетных менеджера.\nИначе это может нарушить работу программы.\e[0m"
                outin_failure
                echo -e -n "\n\e[1;31m$_pkg_manager_folder\n\e[1;37mThere must be 2 package managers in the directory.\nOtherwise it can disrupt the operation of the program.\e[0m"
                outin_failure
                echo -e -n "\n\e[1;37mНедостающие пакеты будут загружены из удаленного репозитория.\e[0m"
                echo -e -n "\n\e[1;37mThe missing packages will be downloaded from the remote repository.\e[0m\n"
                echo ""
                gt_cln_pm
            fi
        else
            echo -e -n "\n\e[1;31m$_pkg_manager_folder\n\e[1;37mДиректория отсутствует.\e[0m"
            outin_failure
            echo -e -n "\n\e[1;31m$_pkg_manager_folder\n\e[1;37mDirectory is not found.\e[0m"
            outin_failure
            echo -e -n "\n\e[1;37mНедостающие пакеты будут загружены из удаленного репозитория.\e[0m"
            echo -e -n "\n\e[1;37mThe missing packages will be downloaded from the remote repository.\e[0m\n"
            echo ""
            gt_cln_pm
        fi
        if [[ -e "$_aur_pkg_winfnts" ]]; then
            echo -e -n "\n\e[1;32m$_aur_pkg_winfnts\n\e[1;37mОбязательный файл присутствует.\e[0m"
            outin_success
            echo -e -n "\n\e[1;32m$_aur_pkg_winfnts\n\e[1;37mThe required file is exists.\e[0m"            
            outin_success
            echo ""
        else
            echo -e -n "\n\e[1;31m$_aur_pkg_winfnts\n\e[1;37mОбязательный файл отсутствует.\e[0m"
            outin_failure
            echo -e -n "\n\e[1;31m$_aur_pkg_winfnts\n\e[1;37mThe required file is not exists.\e[0m"            
            outin_failure
            echo -e -n "\n\e[1;37mНедостающие пакеты будут загружены из удаленного репозитория.\e[0m"
            echo -e -n "\n\e[1;37mThe missing packages will be downloaded from the remote repository.\e[0m\n"
            echo ""
            [[ -e "$_aif_temp_folder" ]] || gt_cln_all
            wait
            cp -f "$_aif_temp_winfnts" "$_aur_pkg_folder"
            wait
        fi
    else
        echo -e -n "\n\e[1;31m$_aur_pkg_folder/\n\e[1;37mОбязатеьная директория отсутствует.\e[0m"
        outin_failure
        echo -e -n "\n\e[1;31m$_aur_pkg_folder/\n\e[1;37mThe required directory is not exists.\e[0m"
        outin_failure
        echo -e -n "\n\e[1;37mНедостающие пакеты будут загружены из удаленного репозитория.\e[0m"
        echo -e -n "\n\e[1;37mThe missing packages will be downloaded from the remote repository.\e[0m\n"
        echo ""
        [[ -e "$_aif_temp_folder" ]] || gt_cln_all
        wait
        mkdir -p "$_aur_pkg_folder"
        cp -Rfa "$_aif_temp_aur_dir"/* "$_aur_pkg_folder"/
        wait
    fi
    unset _temp
    rm -rf "$_aif_temp_folder"
    wait
    sleep 3
    rm -rf "$_rmt_rpstr_info"
    echo -e -n "\nДля обновления пакетов в папке\n$_aur_pkg_folder\nиз удаленного репозитория\n-\nудалите эту папку и перезапустите скрипт.\n" >> "$_rmt_rpstr_info"
    echo -e -n "\nTo update packages in the\n$_aur_pkg_folder\nfolder from the remote repository\n-\ndelete this folder and restart the script.\n" >> "$_rmt_rpstr_info"
    echo "" >> "$_rmt_rpstr_info"
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_rmt_rpstr_ttl" --textbox $_rmt_rpstr_info 0 0
    rm -rf "$_rmt_rpstr_info"
}

