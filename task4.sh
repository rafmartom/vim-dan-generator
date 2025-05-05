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
mdn-html   
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
    /home/fakuve/myrepos/rafmartom/vim-dan-generator/vim-dan-generator.sh "${DOCU}" -p >> /home/fakuve/myrepos/rafmartom/vim-dan-generator/"$(date +"%y-%m-%d")-$(hostname)-parsing.log" 2>&1
done
