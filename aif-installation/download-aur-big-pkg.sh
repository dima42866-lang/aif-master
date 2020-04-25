#!/bin/bash
# https://drive.google.com/open?id=19opqZn3vWylieE_VgIblAGNLRPClpGeP
_ggldrv_url="https://drive.google.com/uc?export=download&id="
_gchrome="19opqZn3vWylieE_VgIblAGNLRPClpGeP"
wget "${_ggldrv_url}${_gchrome}" -O google-chrome-79.0.3945.79-1-x86_64.pkg.tar.xz
wait
# https://drive.google.com/open?id=1Y58XctSDerR6X0fBD9V1-qyLey25u6-R
_oadblock="1Y58XctSDerR6X0fBD9V1-qyLey25u6-R"
wget "${_ggldrv_url}${_oadblock}" -O opera-adblock-complete-11.05.2013-1-any.pkg.tar.xz
wait
# https://drive.google.com/open?id=1GCRdGm6PA-cqiqOFPGNNccXT9zM6Abkj
_operabeta="1GCRdGm6PA-cqiqOFPGNNccXT9zM6Abkj"
wget "${_ggldrv_url}${_operabeta}" -O opera-beta-68.0.3618.36-1-x86_64.pkg.tar.xz
wait
# https://drive.google.com/open?id=1CkQqmsvMHjxbiy4n5dEctgkwe7-SGXg7
_pdfxchange="1CkQqmsvMHjxbiy4n5dEctgkwe7-SGXg7"
wget "${_ggldrv_url}${_pdfxchange}" -O pdf-xchange-8.0.336.0-1-x86_64.pkg.tar.xz
wait
# https://drive.google.com/open?id=13ZChvmNCgrEjOBzfsVu1aS5Hx0u8SOnO
_winepkg="13ZChvmNCgrEjOBzfsVu1aS5Hx0u8SOnO"
wget "${_ggldrv_url}${_winepkg}" -O wine-5.0-6-x86_64.pkg.tar.xz
wait
# https://drive.google.com/open?id=1AWfwtnFJSVod2pKPn8f3MdUC2vsKxw9C
_xnvwmp="1AWfwtnFJSVod2pKPn8f3MdUC2vsKxw9C"
wget "${_ggldrv_url}${_xnvwmp}" -O xnviewmp-0.96-1-x86_64.pkg.tar.xz
wait
exit 0
