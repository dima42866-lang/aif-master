#!/bin/bash
manager_pkg_start()
{
   _pm_uniq=$(find "$_pkg_manager_folder" -maxdepth 1 -type f | rev | cut -d '/' -f1 | rev | cut -d '-' -f1 | sort | uniq -d)
    wait
   _pm_n=$(find "$_pkg_manager_folder" -maxdepth 1 -type f -iname "${_pm_uniq[*]}*" | rev | cut -d '/' -f1 | cut -d '-' -f4-11 | rev)
   wait
   _required_packages=$(find "$_pkg_manager_folder" -maxdepth 1 -type f | rev | cut -d '/' -f1 | cut -d '-' -f4-11 | rev | grep -v "${_pm_uniq[*]}")
   wait
   _pm_menu=""
   for i in ${_pm_n[*]}; do
       _pm_menu="${_pm_menu} $i -"
   done
   _pm_menu="${_pm_menu} $_Back -"
}
function pkgmanager_forms()
{
	if [ -e $_eml_folder ]; then
		dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_msg_pkgs_ttl" --msgbox "$_msg_pkgs_bd" 0 0
		wait
		info_search_pkg
		wait
		manager_pkg_start
		wait
	else
		dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_ynq_pmngr_ttl" --yesno "$_ynq_pmngr_bd" 0 0
		if [[ $? -eq 0 ]]; then
			git clone "$git_pkg_mngr"
			wait
			_gitpkg_clndir=$(echo "$git_pkg_mngr" | rev | cut -d '/' -f1 | rev | sed 's/\.git//')
			wait
			mkdir -p $_pkg_manager_folder
			wait
			find "${_gitpkg_clndir[*]}" -type f -iname "*tar*" -exec cp -f {} $_pkg_manager_folder \;
			wait
			rm -rf "${_gitpkg_clndir[*]}"
			wait
			info_search_pkg
			wait
			manager_pkg_start
			wait
		else
			_pm_once=0
			install_gep
		fi
	fi
}
pkg_manager_install()
{
   if [[ $_pm_once == "0" ]]; then
		_pm_once=1
		pkgmanager_forms
   fi
   dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_menu_pkg_meneger" --menu "$_pm_menu_body" 0 0 2 ${_pm_menu} 2>"${ANSWER}"
   _pm_check=$(cat "${ANSWER}")
   if [[ "${_pm_check[*]}" == "$_Back" ]]; then
       install_gep
   else
       clear
       ustanovka_pocketov "$_pkg_manager_folder" "${_pm_check[*]}"
       wait
       for i in ${_required_packages[*]}; do
           ustanovka_pocketov "$_pkg_manager_folder" "$i"
           wait
       done
       wait
       [[ ${_pm_check} ]] && unset _pm_check
   fi
}
pkg_manager_unset()
{
    ### UNSET ###
    [[ ${_pm_uniq} ]] && unset _pm_uniq
    [[ ${_pm_n} ]] && unset _pm_n
    [[ ${_pm_menu} ]] && unset _pm_menu
    [[ ${_required_packages} ]] && unset _required_packages
    ### UNSET ###
}
