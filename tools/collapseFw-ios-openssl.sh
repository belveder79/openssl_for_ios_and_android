#!/bin/bash

declare -a archs=("armv7" "arm64")

BASE_DIR=$(pwd)/../output/ios
INSTALL_DIR=$BASE_DIR/openssl-framework
rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR/lib

# forward declaration
LIB_NAME2=libcrypto
FINALLIBNAME2=libcrypto.1.1.dylib

LIB_NAME1=openssl
FINALLIBNAME1=libssl.1.1.dylib
LIPSTR="lipo -output $INSTALL_DIR/lib/$FINALLIBNAME1 -create "
for i in ${archs[@]}
do
  LIPSTR+=" $BASE_DIR/openssl-$i/lib/$FINALLIBNAME1"
done
#echo $LIPSTR
`$LIPSTR`

#===================================================
# create a dummy framwork
# set OUT_DIR and LIB_NAME
SOURCE_INFO_PLIST=patches/ios/openssl/Info.plist
FW_PATH="$INSTALL_DIR/$LIB_NAME1.framework"
INFO_PLIST="$FW_PATH/Info.plist"
OUT_DYLIB="$FW_PATH/$LIB_NAME1"

# set the DYLIBS and SOURCE_INFO_PLIST for the library
mkdir -p "$FW_PATH"
mkdir $INSTALL_DIR/$LIB_NAME1.framework/Headers
cp "$SOURCE_INFO_PLIST" "$INFO_PLIST"
cp -R $BASE_DIR/openssl-armv7/include/* $INSTALL_DIR/$LIB_NAME1.framework/Headers
lipo $INSTALL_DIR/lib/$FINALLIBNAME1 -output "$OUT_DYLIB" -create
install_name_tool -id @rpath/$LIB_NAME1.framework/$LIB_NAME1 "$OUT_DYLIB"
for i in ${archs[@]}
do
  install_name_tool -change $BASE_DIR/openssl-$i/lib/$FINALLIBNAME2 @rpath/$LIB_NAME2.framework/$LIB_NAME2 "$OUT_DYLIB"
done


#===================================================

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
SOURCE_INFO_PLIST=patches/ios/libcrypto/Info.plist
FW_PATH="$INSTALL_DIR/$LIB_NAME2.framework"
INFO_PLIST="$FW_PATH/Info.plist"
OUT_DYLIB="$FW_PATH/$LIB_NAME2"

# set the DYLIBS and SOURCE_INFO_PLIST for the library
mkdir -p "$FW_PATH"
mkdir $INSTALL_DIR/$LIB_NAME2.framework/Headers
cp "$SOURCE_INFO_PLIST" "$INFO_PLIST"
cp -R $BASE_DIR/openssl-armv7/include/* $INSTALL_DIR/$LIB_NAME2.framework/Headers
lipo $INSTALL_DIR/lib/$FINALLIBNAME2 -output "$OUT_DYLIB" -create
install_name_tool -id @rpath/$LIB_NAME2.framework/$LIB_NAME2 "$OUT_DYLIB"
