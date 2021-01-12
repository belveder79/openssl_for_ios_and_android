#!/bin/bash

LIB_NAME=curl
declare -a archs=("armv7" "arm64")

BASE_DIR=$(pwd)/../output/ios
INSTALL_DIR=$BASE_DIR/curl-framework
FINALLIBNAME1=libcurl.4.dylib
rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR/lib
#rm $INSTALL_DIR/lib/$FINALLIBNAME1
LIPSTR="lipo -output $INSTALL_DIR/lib/$FINALLIBNAME1 -create "
for i in ${archs[@]}
do
  LIPSTR+=" $BASE_DIR/curl-$i/lib/$FINALLIBNAME1"
done
#echo $LIPSTR
`$LIPSTR`

#===================================================
# create a dummy framwork
# set OUT_DIR and LIB_NAME
SOURCE_INFO_PLIST=patches/ios/curl/Info.plist
FW_PATH="$INSTALL_DIR/$LIB_NAME.framework"
INFO_PLIST="$FW_PATH/Info.plist"
OUT_DYLIB="$FW_PATH/$LIB_NAME"

# set the DYLIBS and SOURCE_INFO_PLIST for the library
mkdir -p "$FW_PATH"
mkdir $INSTALL_DIR/$LIB_NAME.framework/Headers
cp "$SOURCE_INFO_PLIST" "$INFO_PLIST"
cp -R $BASE_DIR/curl-armv7/include/* $INSTALL_DIR/$LIB_NAME.framework/Headers
lipo $INSTALL_DIR/lib/$FINALLIBNAME1 -output "$OUT_DYLIB" -create
install_name_tool -id @rpath/$LIB_NAME.framework/$LIB_NAME "$OUT_DYLIB"

rm -rf $INSTALL_DIR/lib

# reset rpath
for i in ${archs[@]}
do
  install_name_tool -change $BASE_DIR/openssl-$i/lib/libssl.1.1.dylib \
    @rpath/openssl.framework/openssl "$OUT_DYLIB"
  install_name_tool -change $BASE_DIR/openssl-$i/lib/libcrypto.1.1.dylib \
    @rpath/libcrypto.framework/libcrypto "$OUT_DYLIB"
  install_name_tool -change $BASE_DIR/nghttp2-$i/lib/libnghttp2.14.dylib \
    @rpath/nghttp2.framework/nghttp2 "$OUT_DYLIB"
done
#===================================================
# LIB_NAME=curltool
# declare -a archs=("armv7" "arm64")
#
# BASE_DIR=$(pwd)/../output/ios
# INSTALL_DIR=$BASE_DIR/curl-framework
# FINALLIBNAME1=libcurltool.0.dylib
# #rm -rf $INSTALL_DIR
# #mkdir -p $INSTALL_DIR/lib
# rm $INSTALL_DIR/lib/$FINALLIBNAME1
# LIPSTR="lipo -output $INSTALL_DIR/lib/$FINALLIBNAME1 -create "
# for i in ${archs[@]}
# do
#   LIPSTR+=" $BASE_DIR/curl-$i/lib/$FINALLIBNAME1"
# done
# #echo $LIPSTR
# `$LIPSTR`
#
# #===================================================
# # create a dummy framwork
# # set OUT_DIR and LIB_NAME
# SOURCE_INFO_PLIST=patches/ios/curltool/Info.plist
# FW_PATH="$INSTALL_DIR/$LIB_NAME.framework"
# INFO_PLIST="$FW_PATH/Info.plist"
# OUT_DYLIB="$FW_PATH/$LIB_NAME"
#
# # set the DYLIBS and SOURCE_INFO_PLIST for the library
# mkdir -p "$FW_PATH"
# #mkdir $INSTALL_DIR/$LIB_NAME.framework/Headers
# cp "$SOURCE_INFO_PLIST" "$INFO_PLIST"
# #cp -R $BASE_DIR/curl-armv7/include/* $INSTALL_DIR/$LIB_NAME.framework/Headers
# lipo $INSTALL_DIR/lib/$FINALLIBNAME1 -output "$OUT_DYLIB" -create
# install_name_tool -id @rpath/$LIB_NAME.framework/$LIB_NAME "$OUT_DYLIB"
#
# # reset rpath
# for i in ${archs[@]}
# do
#   install_name_tool -change $BASE_DIR/nghttp2-$i/lib/libnghttp2.14.dylib \
#     @rpath/nghttp2.framework/nghttp2 "$OUT_DYLIB"
# done
