#!/bin/bash
ustanovka_pocketov()
{
   _dir="$1"
   _pkg="$2"
   _pkg_full=$(find $_dir -maxdepth 1 -type f -iname "$_pkg*")
   _pkg_name=$(echo "${_pkg_full[*]}" | rev | cut -d '/' -f1 | rev)
   cp -f ${_pkg_full[*]} /var/lib/pacman/local/
   cp -f ${_pkg_full[*]} ${MOUNTPOINT}/var/lib/pacman/local/
   pacman --root ${MOUNTPOINT} --dbpath ${MOUNTPOINT}/var/lib/pacman -U /var/lib/pacman/local/${_pkg_name[*]} --noconfirm
   # DEBUG
   # echo "$_pkg_full"
   # echo "$_pkg_full" >> "$filesdir"/setup-pkgs.txt
   # echo "$_pkg_name"
   # DEBUG
   unset _dir
   unset _pkg
   unset _pkg_full
   unset _pkg_name
}
