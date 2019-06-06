set -x 

SOURCE_DIR=$1
TARGET=$2

function replace_text() {
  START=$(grep -nr "${DELETE_START_PATTERN}" ${SOURCE_DIR}/${FILE} | cut -d':' -f1)
  START=$((${START} + ${START_OFFSET}))
  if [[ ! -z "${DELETE_STOP_PATTERN}" ]]; then
    STOP=$(tail --lines=+${START}  ${SOURCE_DIR}/${FILE} | grep -nr "${DELETE_STOP_PATTERN}" - |  cut -d':' -f1 | head -1)
    CUT=$((${START} + ${STOP} - 1))
  else
    CUT=$((${START}))
  fi
  CUT_TEXT=$(sed -n "${START},${CUT} p" ${SOURCE_DIR}/${FILE})
  sed -i "${START},${CUT} d" ${SOURCE_DIR}/${FILE}

  if [[ ! -z "${ADD_TEXT}" ]]; then
    ex -s -c "${START}i|${ADD_TEXT}" -c x ${SOURCE_DIR}/${FILE}
  fi
}

sed -i 's|#include "third_party/boringssl/src/include/openssl/chacha.h"||g' ${SOURCE_DIR}/http2/test_tools/http2_random.cc
sed -i 's|#include "#include "third_party/boringssl/src/include/openssl/rand.h"|#include "openssl/rand.h"|g' ${SOURCE_DIR}/http2/test_tools/http2_random.cc

FILE="http2/test_tools/http2_random.cc"
DELETE_START_PATTERN="CRYPTO_chacha_20"
DELETE_STOP_PATTERN="counter_++);"
START_OFFSET="0"
ADD_TEXT=""
replace_text
