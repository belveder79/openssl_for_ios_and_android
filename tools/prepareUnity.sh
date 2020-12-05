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
  cp ../output/android/curl-${ABIS[i]}/lib/libcurltool.so $APIOUT/
  cp ../output/android/nghttp2-${ABIS[i]}/lib/libnghttp2.so $APIOUT/
  cp ../output/android/openssl-${ABIS[i]}/lib/libcrypto.so $APIOUT/libcurlcrypto.so
  cp ../output/android/openssl-${ABIS[i]}/lib/libssl.so $APIOUT/libcurlssl.so
  echo "patching elfs..."
  patchelf --set-soname libcurlssl.so $APIOUT/libcurlssl.so
  patchelf --set-soname libcurlcrypto.so $APIOUT/libcurlcrypto.so
  #patchelf --print-soname $APIOUT/libcurlssl.so
  #patchelf --print-soname $APIOUT/libcurlcrypto.so
  patchelf --replace-needed libcrypto.so.1.1 libcurlcrypto.so $APIOUT/libcurlssl.so
  #patchelf --print-needed $APIOUT/libcurlcrypto.so
  patchelf --replace-needed libcrypto.so.1.1 libcurlcrypto.so $APIOUT/libcurl.so
  patchelf --replace-needed libssl.so.1.1 libcurlssl.so $APIOUT/libcurl.so
  #patchelf --print-needed $APIOUT/libcurl.so
  patchelf --replace-needed libcrypto.so.1.1 libcurlcrypto.so $APIOUT/libcurltool.so
  patchelf --replace-needed libssl.so.1.1 libcurlssl.so $APIOUT/libcurltool.so
  #patchelf --print-needed $APIOUT/libcurltool.so
done

echo "Copying iOS... "

cp -R ../output/ios/curl-framework/curl.framework $OUTDIR/iOS/
cp -R ../output/ios/curl-framework/curltool.framework $OUTDIR/iOS/
cp -R ../output/ios/nghttp2-framework/nghttp2.framework $OUTDIR/iOS/
cp -R ../output/ios/openssl-framework/libcrypto.framework $OUTDIR/iOS/
cp -R ../output/ios/openssl-framework/openssl.framework $OUTDIR/iOS/

# run deepsign on all of them
cd $OUTDIR/iOS
/bin/bash deepsign.sh curl
/bin/bash deepsign.sh curltool
/bin/bash deepsign.sh nghttp2
/bin/bash deepsign.sh libcrypto
/bin/bash deepsign.sh openssl
cd $TMPD
