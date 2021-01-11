#!/bin/bash

TMPD=$(pwd)
OUTDIR=../../UNITY_5.1.1f1/Assets/Vendors/Vizario/Plugins/

echo "Copying Android... "

abi=("armeabi-v7a" "arm64-v8a")
ABIS=(${abi[@]})

for ((i = 0; i < ${#ABIS[@]}; i++)); do
  echo "running on ${ABIS[i]} ..."
  APIOUT=$OUTDIR/Android/libs/${ABIS[i]}
  cp ../output/android/curl-${ABIS[i]}/lib/libcurl.so $APIOUT/
  #cp ../output/android/curl-${ABIS[i]}/lib/libcurltool.so $APIOUT/
  cp ../output/android/nghttp2-${ABIS[i]}/lib/libnghttp2.so $APIOUT/
  cp ../output/android/openssl-${ABIS[i]}/lib/libcurlcrypto.so $APIOUT/
  cp ../output/android/openssl-${ABIS[i]}/lib/libcurlssl.so $APIOUT/
done

echo "Copying iOS... "

cp -R ../output/ios/curl-framework/curl.framework $OUTDIR/iOS/
#cp -R ../output/ios/curl-framework/curltool.framework $OUTDIR/iOS/
cp -R ../output/ios/nghttp2-framework/nghttp2.framework $OUTDIR/iOS/
cp -R ../output/ios/openssl-framework/libcrypto.framework $OUTDIR/iOS/
cp -R ../output/ios/openssl-framework/openssl.framework $OUTDIR/iOS/
