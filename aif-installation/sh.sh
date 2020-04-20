#!/bin/bash
filesdir="."
source ./config/list-pkg-forms.sh
git clone "$git_eml_pkg"
wait
_gitpkg_clndir=$(echo "$git_eml_pkg" | rev | cut -d '/' -f1 | rev | sed 's/\.git//')
wait
mkdir -p $_eml_folder
wait
find "${_gitpkg_clndir[*]}" -type f -iname "*tar*" -exec cp -f {} $_eml_folder \;
wait
rm -rf "${_gitpkg_clndir[*]}"


arch-chroot $MOUNTPOINT /bin/bash -c "Xorg -configure"
wait
sudo find ${MOUNTPOINT}/root/ -maxdepth 1 -iname "xorg.*" -exec cp -f {} ${MOUNTPOINT}/etc/X11/xorg.conf \;
wait


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
			git clone "$git_eml_pkg"
			wait
			_gitpkg_clndir=$(echo "$git_eml_pkg" | rev | cut -d '/' -f1 | rev | sed 's/\.git//')
			wait
			mkdir -p $_eml_folder
			wait
			find "${_gitpkg_clndir[*]}" -type f -iname "*tar*" -exec cp -f {} $_eml_folder \;
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

exit 0
