#!/bin/bash
export ANDROID_NDK_ROOT=~/Development/Android/android-ndk-r19c
export ANDROID_HOME=~/Development/Android/sdk
export ANDROID_NDK_r16b=~/Development/Android/android-ndk-r16b
export POLLY_ROOT=~/Development/AR4/VIZARIO.FIND/polly_bel

/bin/bash build-android-openssl.sh;
/bin/bash build-android-nghttp2.sh;
/bin/bash build-android-curl.sh;
/bin/bash build-ios-openssl.sh;
/bin/bash build-ios-nghttp2.sh;
/bin/bash build-ios-curl.sh;
/bin/bash collapseFw-ios-openssl.sh;
/bin/bash collapseFw-ios-nghttp2.sh;
/bin/bash collapseFw-ios-curl.sh;
/bin/bash patchAndSign.sh;
