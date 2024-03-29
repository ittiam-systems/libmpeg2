#!/bin/bash -eu
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
# Ensure SRC and WORK are set
test "${SRC}" != "" || exit 1
test "${WORK}" != "" || exit 1
test "${OUT}" != "" || exit 1

#Opt out of shift sanitizers in undefined sanitizer
if [[ $SANITIZER = *undefined* ]]; then
  CFLAGS="$CFLAGS -fno-sanitize=shift"
  CXXFLAGS="$CXXFLAGS -fno-sanitize=shift"
fi

# Build libmpeg2
build_dir=$WORK/build
rm -rf ${build_dir}
mkdir -p ${build_dir}
pushd ${build_dir}

cmake $SRC/libmpeg2
make -j$(nproc) mpeg2_dec_fuzzer
cp ${build_dir}/mpeg2_dec_fuzzer $OUT/
popd

cp $SRC/mpeg2_dec_fuzzer_seed_corpus.zip $OUT/mpeg2_dec_fuzzer_seed_corpus.zip
cp $SRC/libmpeg2/fuzzer/mpeg2_dec_fuzzer.dict $OUT/mpeg2_dec_fuzzer.dict
