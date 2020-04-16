#!/bin/bash
# _your_users=$(ls ${MOUNTPOINT}/home/ | sed "s/lost+found//")
_your_users=$(ls /home/ | sed "s/lost+found//")
_data_file_name="./data-files"
_your_data=""
declare -i count
for j in ${_your_users[*]}; do
	count=$(groups $j | grep -Ei "wheel" | wc -l)
	if [[ $count -eq 1 ]]; then
		_your_data="$j mikl" # read -s -p "Please, enter the password" pass
		break
	fi
done
echo "_your_data=\"${_your_data[*]}\"" > $_data_file_name
exit 0
