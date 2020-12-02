#!/bin/bash
#
# Copyright 2016 leenjewel
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# read -n1 -p "Press any key to continue..."

set -u

source ./build-ios-common.sh

if [ -z ${version+x} ]; then
  version="7.73.0"
fi

TOOLS_ROOT=$(pwd)

SOURCE="$0"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
pwd_path="$(cd -P "$(dirname "$SOURCE")" && pwd)"

echo pwd_path=${pwd_path}
echo TOOLS_ROOT=${TOOLS_ROOT}

LIB_VERSION="curl-$(echo $version | sed 's/\./_/g')"
LIB_NAME="curl-$version"
LIB_DEST_DIR="${pwd_path}/../output/ios/curl-universal"

init_log_color

#echo "https://github.com/curl/curl/releases/download/${LIB_VERSION}/${LIB_NAME}.tar.gz"

# https://curl.haxx.se/download/${LIB_NAME}.tar.gz
# https://github.com/curl/curl/releases/download/curl-7_69_0/curl-7.69.0.tar.gz
# https://github.com/curl/curl/releases/download/curl-7_68_0/curl-7.68.0.tar.gz
DEVELOPER=$(xcode-select -print-path)
rm -rf "${LIB_DEST_DIR}" "${LIB_NAME}"
#[ -f "${LIB_NAME}.tar.gz" ] || curl -LO https://github.com/curl/curl/releases/download/${LIB_VERSION}/${LIB_NAME}.tar.gz >${LIB_NAME}.tar.gz
[ -f "${LIB_NAME}.zip" ] || curl -LO https://github.com/belveder79/curl/archive/master.zip
mv master.zip ${LIB_NAME}.zip
rm curl_build_tools_7.73.0.zip
wget -c https://www.dropbox.com/s/e28hdim9l87xdna/curl_build_tools_7.73.0.zip

function configure_make() {

    ARCH=$1
    SDK=$2
    PLATFORM=$3
    SDK_PATH=$(xcrun -sdk ${SDK} --show-sdk-path)

    log_info "configure $ARCH start..."

    if [ -d "${LIB_NAME}" ]; then
        rm -fr "${LIB_NAME}"
    fi
    #tar xfz "${LIB_NAME}.tar.gz"
    unzip -q ${LIB_NAME}.zip
    mv curl-master ${LIB_NAME}
    pushd .
    cd "${LIB_NAME}"
    unzip -o ../curl_build_tools_7.73.0.zip

    PREFIX_DIR="${pwd_path}/../output/ios/curl-${ARCH}"
    if [ -d "${PREFIX_DIR}" ]; then
        rm -fr "${PREFIX_DIR}"
    fi
    mkdir -p "${PREFIX_DIR}"

    OUTPUT_ROOT=${TOOLS_ROOT}/../output/ios/curl-${ARCH}
    mkdir -p ${OUTPUT_ROOT}/log

    set_ios_cpu_feature "curl" "${ARCH}" "${IOS_MIN_TARGET}" "${SDK_PATH}"

    OPENSSL_OUT_DIR="${pwd_path}/../output/ios/openssl-${ARCH}"
    NGHTTP2_OUT_DIR="${pwd_path}/../output/ios/nghttp2-${ARCH}"

    export LDFLAGS="${LDFLAGS} -L${OPENSSL_OUT_DIR}/lib -L${NGHTTP2_OUT_DIR}/lib"
    export CFLAGS="${CFLAGS} -DCUSTOM_API_EXPORT"

    ios_printf_global_params "$ARCH" "$SDK" "$PLATFORM" "$PREFIX_DIR" "$OUTPUT_ROOT"

    if [[ "${ARCH}" == "x86_64" ]]; then

        ./Configure --host=$(ios_get_build_host "$ARCH") --prefix="${PREFIX_DIR}" --enable-ipv6 --without-libidn2 --with-ssl=${OPENSSL_OUT_DIR} --with-nghttp2=${NGHTTP2_OUT_DIR} >"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1

    elif [[ "${ARCH}" == "armv7" ]]; then

        ./Configure --host=$(ios_get_build_host "$ARCH") --prefix="${PREFIX_DIR}" --enable-ipv6 --with-ssl=${OPENSSL_OUT_DIR} --with-nghttp2=${NGHTTP2_OUT_DIR} >"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1

    elif [[ "${ARCH}" == "arm64" ]]; then

        ./Configure --host=$(ios_get_build_host "$ARCH") --prefix="${PREFIX_DIR}" --enable-ipv6 --with-ssl=${OPENSSL_OUT_DIR} --with-nghttp2=${NGHTTP2_OUT_DIR} >"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1

    elif [[ "${ARCH}" == "arm64e" ]]; then

        ./Configure --host=$(ios_get_build_host "$ARCH") --prefix="${PREFIX_DIR}" --enable-ipv6 --with-ssl=${OPENSSL_OUT_DIR} --with-nghttp2=${NGHTTP2_OUT_DIR} >"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1

    else
        log_error "not support" && exit 1
    fi

    log_info "make $ARCH start..."

    make clean >>"${OUTPUT_ROOT}/log/${ARCH}.log"
    if make -j8 >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1; then
        make install >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1
        cp src/.libs/libcurltool.0.dylib ${PREFIX_DIR}/lib
    fi

    popd
}

log_info "${PLATFORM_TYPE} ${LIB_NAME} start..."

for ((i = 0; i < ${#ARCHS[@]}; i++)); do
    if [[ $# -eq 0 || "$1" == "${ARCHS[i]}" ]]; then
        configure_make "${ARCHS[i]}" "${SDKS[i]}" "${PLATFORMS[i]}"
    fi
done

log_info "lipo start..."

function lipo_library() {
    LIB_SRC=$1
    LIB_DST=$2
    LIB_PATHS=("${ARCHS[@]/#/${pwd_path}/../output/ios/curl-}")
    LIB_PATHS=("${LIB_PATHS[@]/%//lib/${LIB_SRC}}")
    lipo ${LIB_PATHS[@]} -create -output "${LIB_DST}"
}
mkdir -p "${LIB_DEST_DIR}"
lipo_library "libcurl.a" "${LIB_DEST_DIR}/libcurl-universal.a"

log_info "${PLATFORM_TYPE} ${LIB_NAME} end..."
