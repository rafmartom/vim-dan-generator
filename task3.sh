#!/bin/bash

DOCU_LIST=(
#adobe-ae
#adobe-ai
#adobe-extendscript
#adobe-ppro
#adobe-psd
#angular
#cppreference
#docker
#google-cloud-A
#google-cloud-BtoC
#google-cloud-DtoR
#google-cloud-S
#google-cloud-TtoZ
#google-devs-ad-manager
#google-devs-android
#google-devs-apps-script
#google-devs-display-video
#google-devs-drive
#google-devs-gmail
#google-devs-google-ads
#google-devs-maps
#google-devs-rest
#google-devs-search
#js-cheerio
#js-nextjs
#js-react
#man7
#mdn-css    
#mdn-html   
mdn-http   
mdn-js     
mdn-rest   
mdn-svg    
mdn-webapi 
#node-express
#node-puppeteer
#npm-package
#pandoc
#py-docs
#py-llamaindex
#react-native
#ts-lang
#ts-llamaindex
#vimhelp
#wireshark
#zaproxy
)

for DOCU in "${DOCU_LIST[@]}"; do
    ctags --options=NONE --options=/home/fakuve/myrepos/rafmartom/vim-dan-generator/ctags-rules/dan.ctags --tag-relative=always -f /home/fakuve/downloads/vim-dan/.tags"${DOCU}" /home/fakuve/downloads/vim-dan/"${DOCU}".dan

done
