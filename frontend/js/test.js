const arr = [];
arr["a"] = 1;
arr["0"] = 2;
arr.forEach((val) => console.log(val)); // 不会输出任何值，因为 arr 是一个空数组
console.log(arr.length); // 输出: 2，因为 '1' 转换后是有效索引，而 'a' 不是
