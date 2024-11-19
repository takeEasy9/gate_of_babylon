const str = "aaaaccdffgg";
const charCount = {};

// 普通写法
for (let i = 0; i < str.length; i++) {
  const char = str[i];
  if (charCount[char]) {
    charCount[char]++;
  } else {
    charCount[char] = 1;
  }
}
console.log(charCount);

// reduce写法
const charCount2 = str.split("").reduce((acc, char) => {
  return acc[char]++ || (acc[char] = 1), acc;
}, {});
console.log(charCount2);
