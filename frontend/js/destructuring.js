// js 解构
const person = {
  name: "zhangsan",
  age: 18,
  address: "美国",
};
const { age = 20, address: addr = "美国" } = person;
console.log(age);
console.log(addr);
