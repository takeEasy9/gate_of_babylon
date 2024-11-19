/**
 * 仿照 java 的 BigDecimal 实现加法运算
 * @param {*} a
 * @param {*} b
 * @returns
 */
const SPECIAL_CHAR_ZERO = "0";
const SPECIAL_CHAR_DOT = ".";
function splitNum(num) {
  num ??= "0";
  return num.includes(".") ? num.split(".") : [num, "0"];
}
function addByChar(a, b, padFn) {
  const len = Math.max(a.length, b.length);
  a = a[padFn](len, SPECIAL_CHAR_ZERO);
  b = b[padFn](len, SPECIAL_CHAR_ZERO);
  let carry = 0;
  let res = "";
  for (let i = len - 1; i >= 0; i--) {
    const sum = +a[i] + +b[i] + carry;
    res = (sum % 10) + res;
    carry = Math.floor(sum / 10);
  }
  return [res, carry];
}

function sum(a, b) {
  a ||= SPECIAL_CHAR_ZERO;
  b ||= SPECIAL_CHAR_ZERO;
  const [aInt, aDec] = splitNum(a);
  const [bInt, bDec] = splitNum(b);
  const [decRes, decCarry] = addByChar(aDec, bDec, "padEnd");
  const aIntPlusCarry = String(+aInt + decCarry);
  let [intRes, intCarry] = addByChar(aIntPlusCarry, bInt, "padStart");
  intRes = intCarry ? intCarry + intRes : intRes;
  return a.includes(SPECIAL_CHAR_DOT) || b.includes(SPECIAL_CHAR_DOT)
    ? intRes + "." + decRes
    : intRes;
}
