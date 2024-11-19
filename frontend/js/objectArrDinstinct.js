// 对象数组去重
// 对象均为Plain Object
// 只要对象的所有属性的值相同，则表示是相同对象
const arr = [
  { a: 1, b: 2 },
  { b: 2, a: 1 },
  { a: 1, b: 2, c: { a: 1, b: 2 } },
  { b: 2, a: 1, c: { b: 2, a: 1 } },
];
const newArr = [...arr];
for (let i = 0; i < newArr.length; i++) {
  for (let j = i + 1; j < newArr.length; j++) {
    // 如果两个对象相等，则删除后一个对象
    if (equals(newArr[i], newArr[j])) {
      newArr.splice(j, 1);
      j--;
    }
  }
}
console.log(newArr);

function isObject(obj) {
  return Object.prototype.toString.call(obj) === "[object Object]";
}
function equals(obj1, obj2) {
  if (isObject(obj1) && isObject(obj2)) {
    const keys1 = Object.keys(obj1);
    const keys2 = Object.keys(obj2);
    if (keys1.length !== keys2.length) {
      return false;
    }
    for (let key of keys1) {
      if (!keys2.includes(key)) {
        return false;
      }
      if (!equals(obj1[key], obj2[key])) {
        return false;
      }
    }
    return true;
  } else {
    return obj1 === obj2;
  }
}
console.log("end");
