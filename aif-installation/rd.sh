#!/bin/bash
_data_file_name="./data-files"
[ -e $_data_file_name ] && source $_data_file_name
_info_array=( $_your_data )
unset _your_data
echo "${_info_array[1]}" | sudo -u ${_info_array[0]} -S systemctl is-active NetworkManager
exit 0
