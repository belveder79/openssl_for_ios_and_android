#/bin/bash

#CSID="iPhone Developer: Clemens Arth (G58ALF4GPN)"
CSID="Apple Development: Clemens Arth (G58ALF4GPN)"
#CSID2="Apple Distribution: AR4 GmbH (4Y44NLQV57)"
#CSID="Apple Development: clemens.arth@gmx.at (8YM9MDV4EC)"
LIB_NAME=$1

# decompose first, then codesign all, then recompose
ARCHS=`lipo -archs $LIB_NAME.framework/$LIB_NAME`
for i in $ARCHS
do
  lipo $LIB_NAME.framework/$LIB_NAME -extract $i -output $LIB_NAME-$i
  codesign -f -s "$CSID" $LIB_NAME-$i
done
rm $LIB_NAME.framework/$LIB_NAME

LIPSTR="lipo -output $LIB_NAME.framework/$LIB_NAME -create "
for i in $ARCHS
do
  LIPSTR+=" $LIB_NAME-$i"
done
`$LIPSTR`
rm $LIB_NAME-*

#DYNAME=libZXingCore.1.dylib
## decompose first, then codesign all, then recompose
#ARCHS=`lipo -archs $LIB_NAME.framework/$DYNAME`
#for i in $ARCHS
#do
#  lipo $LIB_NAME.framework/$DYNAME -extract $i -output $DYNAME-$i
#  codesign -f -s "$CSID" $DYNAME-$i
#done
#rm $LIB_NAME.framework/$DYNAME
#
#LIPSTR="lipo -output $LIB_NAME.framework/$DYNAME -create "
#for i in $ARCHS
#do
#  LIPSTR+=" $DYNAME-$i"
#done
#`$LIPSTR`
#rm $DYNAME-*

codesign -f --deep -s "$CSID" $LIB_NAME.framework
