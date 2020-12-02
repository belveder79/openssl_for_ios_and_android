#!/bin/bash

LIB_NAME=openssl
declare -a archs=("armv7" "arm64")

BASE_DIR=$(pwd)/../output/ios
INSTALL_DIR=$BASE_DIR/openssl-framework
FINALLIBNAME1=libcrypto.1.1.dylib
rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR/lib
rm $INSTALL_DIR/lib/$FINALLIBNAME1
LIPSTR="lipo -output $INSTALL_DIR/lib/$FINALLIBNAME1 -create "
for i in ${archs[@]}
do
  LIPSTR+=" $BASE_DIR/openssl-$i/lib/$FINALLIBNAME1"
done
#echo $LIPSTR
`$LIPSTR`

FINALLIBNAME2=libssl.1.1.dylib
rm $INSTALL_DIR/lib/$FINALLIBNAME2
LIPSTR="lipo -output $INSTALL_DIR/lib/$FINALLIBNAME2 -create "
for i in ${archs[@]}
do
  LIPSTR+=" $BASE_DIR/openssl-$i/lib/$FINALLIBNAME2"
done
#echo $LIPSTR
`$LIPSTR`

#===================================================
# create a dummy framwork
# set OUT_DIR and LIB_NAME
SOURCE_INFO_PLIST=patches/ios/Info.plist
FW_PATH="$INSTALL_DIR/$LIB_NAME.framework"
INFO_PLIST="$FW_PATH/Info.plist"
OUT_DYLIB="$FW_PATH/$LIB_NAME"

# set the DYLIBS and SOURCE_INFO_PLIST for the library
mkdir -p "$FW_PATH"
mkdir $INSTALL_DIR/$LIB_NAME.framework/Headers
cp "$SOURCE_INFO_PLIST" "$INFO_PLIST"
cp -R $BASE_DIR/openssl-armv7/include/* $INSTALL_DIR/$LIB_NAME.framework/Headers
lipo $INSTALL_DIR/lib/$FINALLIBNAME2 -output "$OUT_DYLIB" -create
cp $INSTALL_DIR/lib/$FINALLIBNAME1 $INSTALL_DIR/$LIB_NAME.framework
install_name_tool -id @rpath/$LIB_NAME.framework/$LIB_NAME "$OUT_DYLIB"
# reset rpath
install_name_tool -id @rpath/$LIB_NAME.framework/$FINALLIBNAME1 $INSTALL_DIR/$LIB_NAME.framework/$FINALLIBNAME1
for i in ${archs[@]}
do
  install_name_tool -change $BASE_DIR/openssl-$i/lib/$FINALLIBNAME1 @rpath/$LIB_NAME.framework/$FINALLIBNAME1 "$OUT_DYLIB"
done
#===================================================
