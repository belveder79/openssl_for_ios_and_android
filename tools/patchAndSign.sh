#!/bin/bash

TMPD=$(pwd)

echo "Patching Android... "
abi=("armeabi-v7a" "arm64-v8a")
ABIS=(${abi[@]})

for ((i = 0; i < ${#ABIS[@]}; i++)); do
  echo "running on ${ABIS[i]} ..."
  FOLDER=../output/android/openssl-${ABIS[i]}/lib
  echo "patching elfs..."
  cp $FOLDER/libssl.so $FOLDER/libcurlssl.so
  patchelf --set-soname libcurlssl.so $FOLDER/libcurlssl.so
  cp $FOLDER/libcrypto.so $FOLDER/libcurlcrypto.so
  patchelf --set-soname libcurlcrypto.so $FOLDER/libcurlcrypto.so
  #patchelf --print-soname $APIOUT/libcurlssl.so
  #patchelf --print-soname $APIOUT/libcurlcrypto.so
  patchelf --replace-needed libcrypto.so.1.1 libcurlcrypto.so $FOLDER/libcurlssl.so
  #patchelf --print-needed $APIOUT/libcurlcrypto.so
  FOLDER=../output/android/curl-${ABIS[i]}/lib
  patchelf --replace-needed libcrypto.so.1.1 libcurlcrypto.so $FOLDER/libcurl.so
  patchelf --replace-needed libssl.so.1.1 libcurlssl.so $FOLDER/libcurl.so
  #patchelf --print-needed $APIOUT/libcurl.so
  patchelf --replace-needed libcrypto.so.1.1 libcurlcrypto.so $FOLDER/libcurltool.so
  patchelf --replace-needed libssl.so.1.1 libcurlssl.so $FOLDER/libcurltool.so
  #patchelf --print-needed $APIOUT/libcurltool.so
done

echo "Patching iOS... "

FOLDER=../output/ios/curl-framework
cp deepsign.sh $FOLDER/ && cd $FOLDER && /bin/bash deepsign.sh curl && /bin/bash deepsign.sh curltool && rm deepsign.sh && cd $TMPD
FOLDER=../output/ios/nghttp2-framework
cp deepsign.sh $FOLDER/ && cd $FOLDER && /bin/bash deepsign.sh nghttp2 && rm deepsign.sh && cd $TMPD
FOLDER=../output/ios/openssl-framework
cp deepsign.sh $FOLDER/ && cd $FOLDER && /bin/bash deepsign.sh openssl && /bin/bash deepsign.sh libcrypto && rm deepsign.sh && cd $TMPD
