#!/bin/bash
# https://drive.google.com/open?id=19opqZn3vWylieE_VgIblAGNLRPClpGeP
# https://drive.google.com/file/d/1UcJ8gWZ4WfBC97McqaSPaP6UmDg1aIvE/view?usp=sharing
_ggldrv_url="https://drive.google.com/uc?export=download&id="
_gchrome="1UcJ8gWZ4WfBC97McqaSPaP6UmDg1aIvE"
wget "${_ggldrv_url}${_gchrome}" -O google-chrome-84.0.4147.89-1-x86_64.pkg.tar.zst
wait
# https://drive.google.com/file/d/1Md2T4dnrp_ICKmR46JHdkpNeajuBPE82/view?usp=sharing
_gchrome_dev="1Md2T4dnrp_ICKmR46JHdkpNeajuBPE82"
wget "${_ggldrv_url}${_gchrome_dev}" -O google-chrome-dev-86.0.4214.2-1-x86_64.pkg.tar.zst
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
# https://drive.google.com/file/d/1c2xVmn72o9LZGV_d1GW7SCFxX_6wAXX_/view?usp=sharing
_rstudio="1c2xVmn72o9LZGV_d1GW7SCFxX_6wAXX_"
wget "${_ggldrv_url}${_rstudio}" -O rstudio-desktop-bin-1.3.959-1-x86_64.pkg.tar.zst
wait
# https://drive.google.com/file/d/1kFUpj2KJYhb-5GCutMPzR6_uoBhR9vNR/view?usp=sharing
_viber="1kFUpj2KJYhb-5GCutMPzR6_uoBhR9vNR"
wget "${_ggldrv_url}${_viber}" -O viber-13.3.1.22-1-x86_64.pkg.tar.zst
wait
# https://drive.google.com/file/d/1Gl_tMfTYIesYp-4awnhMeeRisMpPOiI-/view?usp=sharing
_whatsapp="1Gl_tMfTYIesYp-4awnhMeeRisMpPOiI-"
wget "${_ggldrv_url}${_whatsapp}" -O whatsapp-nativefier-2.2033.7-1-x86_64.pkg.tar.zst
wait
exit 0
