## 前端面试题

[toc]

## JavaScript 基础知识

### 1 ) 手写Promise

Promises/A+: Promise 规范 [Link &rarr;]([Promises/A+中文网 (promisesaplus.com.cn)](https://promisesaplus.com.cn/))，[代码实现](js/promise.html)

[参考实现1]([javascript - 手写一个Promise/A+,完美通过官方872个测试用例 - 进击的大前端 - SegmentFault 思否](https://segmentfault.com/a/1190000023157856))

[参考实现2]([手写Promise第一章_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV19SmjY8EFU/?spm_id_from=333.337.search-card.all.click&vd_source=a44de6033b8c062af031b64fe746f310))

### 2）async 与 await

ES7 推出了async 与 await关键字。

async 关键字用于修饰函数，标记函数为异步的，被它修饰地函数总是返回一个Promise。

await 关键字迫使JavaScript解释器"暂停"执行并等待结果。

```
async function m() {
	console.log(0)
	const n await 1
	console.log(n)
}
等价于
function m() {
	console.log(0)
	return Promise.resolve(1).then((n)=>{
		console.log(n)
	})
}
```

PS: Promise.then方法回调会放到微任务队列中，微任务队列优先级高于宏任务队列。

setTimeout、setInterval、事件处理函数属于宏任务。

### 3）如何消除异步的传递性

React 代数效应。

### 4） 数字精度相关题

浮点数的存储、运算、显示都是不精确的。

#### 4.1） toFixed 函数

1.55.toFixed(1) = 1.6

3.55.toFixed(1) = 3.5

decimal.js 库解决js中数字不精确问题，存储、运算都以字符串形式。

银行家算法： 1234 舍去， 6789入， 5看情况。

#### 4.2）手写数字字符串运算，解决大整数相加与浮点数运算精度问题

### 5）对象数组去重？

递归比较对象属性值

### 6）手写发布订阅模式

[发布订阅模式实现 &rarr;](subscrbePattern.js)

### 7）JS 对象解构

```
const { age, address } = person // 最基础的解构
const { age = 20, address = "美国" } = person // 解构时设置默认值
const { age = 20, address： addr = "美国" } = person // 解构时重命名
```

### 8）`==`、`===`、Object.is() 三者之间的区别

== 非严格相等比较：

1.  如果一个值是 null 另一个值是 undefined，返回 true。
2. NaN 与 NaN 比较，返回 false。

3.  如果两个值的类型相同，执行严格比较。

4.  如果两个操作数类型不同，则进行类型转换后再进行比较。规则如下：

1. 如果一个操作数是数值 (number)， 另一个操作数是字符串，则将**字符串转换为数值**，然后进行比较。
2. 如果一个操作数是布尔值，将**布尔值转换为数值**再比较，true 转换为 1，false 转换为 0 。
3. 如果一个操作数是对象，将对**象转换为原始值**再比较，对象转换原始值通常先调用 `valueOf()` 方法，当 `valueOf()` 方法 返回的不是**基本类型**时，再调用 `toString()` 方法 。

=== 和 Object.is() 比较规则：

=== 和 Object.is() 比较时都不会进行类型转换。

Object.is()：

当比较 NaN 时，Object.is (NaN, NaN) 返回 true。
当比较 +0 和 -0 时，Object.is (+0, -0) 返回 false，因为它能区分正零和负零（所以我们在日常开发中，如要区分正负，应该用 Object.is ）。

===：

NaN `===` NaN 返回 false。因为 NaN 是不等于任何值，包括它自身。
对于 +0 和 -0，+0 === -0 返回 true，因为**严格相等不区分正负**。

判断两个值是否相等的**通用方法**，参考 Vue 源码 hasChanged 方法

```
function isEqual(val1: any, val2: any): boolean {
    return val1 !== val2 && (val1 === val1 || val2 === val2)
}
```

### 9）null 与 undefine 的区别

JavaScript 作者 BrendanErich 的解释

null： no object

undefined：no value

变量引用存在但本身指向的值就是null。

undefined指的是这个引用本身不存在。

### 10）Object、object、{}的区别

Object：支持所有的引用类型与原始类型, 声明为Object类型的对象变量不能再添加属性。

object：非原始类型的，常用于泛型约束，用于表示引用类型。

{}： 空对象，与Object等价，该类型的变量可以赋值任何类型， 缺点与Object相同。

### 11）typescript 中 any、unknown、void、never类型的区别

any: 任何类型，任何类型的变量都可赋值any类型的变量，any类型的变量也可赋值类任何其他类型的变量。

unknown：比any更加严格，unknown类型的变量只能赋值给unknown或any类型。

void: 常用于函数返回类型，表示该函数无返回值。

never: 不存在的类型，比如交叉类型 type A = number & string

### 12） ES 模块和 CommonJS 模块化方案有什么区别？

ES（ECMAScript）： ES 模块化是由 ECMAScript 标准规定的，属于 JavaScript 语言本身的一部分。它在 ES6（ECMAScript 2015）中被引入，并已成为 JavaScript 的标准模块化方案。

CommonJS：CommonJS 是 Node.js 中使用的模块化规范，最初是为了解决 JavaScript 在服务器端的模块化问题而创建的。虽然它不是 JavaScript 语言的一部分，但在 Node.js 生态系统中得到了广泛应用。

ES 模块：ES 模块使用 **import** 和 **export** 关键字来导入和导出模块。它支持静态解析，模块加载是异步的，模块的引用是动态的。

CommonJS：CommonJS 使用 require() 函数来导入模块，使用 module.exports 或 exports 来导出模块。它是同步加载的，模块的引用是静态的。

ES 模块：ES 模块广泛应用于现代的 Web 开发中，可以在浏览器环境和 Node.js 环境中使用。

CommonJS：CommonJS 主要用于 Node.js 环境，用于组织服务器端的 JavaScript 代码，例如构建 web 服务器、文件系统操作等。

ES 模块：ES 模块的静态解析意味着模块的依赖关系在代码执行前已经确定，因此它不支持动态导入。

CommonJS：CommonJS 支持**动态导入**，可以在运行时根据条件加载模块。

ES 模块中 export 出去的对象能被修改么？

在 ES 模块中，export 出去的对象默认是只读的，不能被修改。当一个对象被导出后，在其他模块中引入该对象时，只能读取其属性和方法，而不能修改它们。

### 13）var、let、const 的区别

1. 存在全局污染，var 声明的变量存在全局污染，其声明的变量是全局作用域或函数作用域。
2. 块级作用域，var 其声明的变量是全局作用域和函数作用域, let 和 const 都是块作用域。
3. TDZ 暂时性死区。
4. 重复声明，var 允许重复声明，后面的值覆盖前面的值，let 和 const 不允许。

### 14）箭头函数与普通函数的区别

函数：一组指令的封装。、

ES6 提出箭头函数解决 JS 函数的二义性。

箭头函数的特点：

- 没有 this、super、arguments，因为没有 this ，故无法通过任何手段绑定 this。
- 不能使用 new 调用。
- 没有原型。

如何解决函数的二义性？

解决方法一：使用 class 定义构造数。

决绝方法二：使用 new.target 判断函数类型。

 ### 15）作用域链查找过程?

考查一：

```
var test = 'baz'
(function () {
  test = 'foo'
  console.log(test)
})()
输出： foo
```

考查二：

```
var test = 'baz'
(function test() {
 test = 'foo'
  console.log(test)
})()
输出： test 函数
```

**变量遮蔽（shadowing）** 在函数内部引用 test 时，会查找最近的作用域里的 test 的变量或函数，而不会查找外部作用域的。在这种情况下，函数 test 遮蔽了外部的 test 变量。 会查找最近作用域里的test。

函数的名称是**只读**的，所以不能在函数内部修改函数的名称。因此， 函数内部 test = "foo" 这行代码其实是无效的。

### 16）箭头函数 this 指向

```
// 浏览器环境
var length = 1;
function fun() {
console.log(this.length);
}
let arr = [fun, "a", "b"];
arr[0](); // 输出 3, arr是 fun 调用的上下文。
let fun2 = arr[0];
fun2(); // 输出 1, 此时 fun2 的上下文是全局上下文。
```

### 17）短路规则

&& 和 || 逻辑运算符操作数不是布尔值，需要使用短路规则来判断返回结果。

与运算符（&&）短路规则

如果第一个操作数是**假值**，则返回第一个操作数的值。

如果第一个操作数为**真值**，则返回第二个操作数的值。

或运算符（||）短路规则

如果第一个操作数是**真值**，则返回第一个操作数的值。

如果第一个操作数为**假值**，则返回第二个操作数的值。

如果有n个操作数的短路规则

逻辑与（&&）：从左往右返回第一个遇到的假值。如果全部是真值则返回最后一个操作数的值。

逻辑或（||）：从左往右返回第一个遇到的真值。如果所有操作数是假值，则返回最后一个操作数的值。

### 18）实例方法与原型方法的区别

```
function Person () {
    // 静态方法，直接添加到函数上，可以直接通过 Person.say() 方法调用
    Person.say = function () {
      console.log ("a");
    };
    // 实例方法，想要访问该方法，必须通过 new 生成 Person 实例，然后通过实例调用。每个对象独有的。
    this.say = function () {
    console.log ("b");
    };
}
// 定义在 Person 的原型上，通过 Person.prototype.say 来访问。	这意味着所有通过 Person 构造函数创建的实例都会共享这个方法。
Person.prototype.say = function () {
	console.log ("c");
};
// 静态方法
Person.say = function () {
	console.log ("d");
};
Person.say (); // 输出 d
var obj = new Person ();
obj.say (); // 输出 b
Person.say (); // 输出 a
```

### 19）forEach的实现原理是什么？循环中添加删除元素，会影响循环次数吗？

**添加元素**：forEach 在循环开始前就已经确定循环次数， 添加元素不会影响循环次数。

```
const numbersOne = [1, 2, 3];
// forEach 中添加元素, 影响循环次数吗？
numbersOne.forEach((number, index) => {
  console.log(number);
  numbersOne.push(number + 3);
});
console.log("numbersOne的最终结果", numbersOne);
```

**删除元素**：ECMA 规范， 循环时会判断当前遍历的索引是否是数组的属性，如果是则执行 forEach 回调， 否则不会执行。

```
// forEach 中删除元素, 影响循环次数吗？
const numbersTwo = [1, 2, 3];
numbersTwo.forEach((number, index) => {
  console.log(number);
  numbersTwo.pop();
});
console.log("numbersTwo的最终结果", numbersTwo);
```

forEach 中使用 **splice** 方法：

```
// 输出 1，3
const array1 = [1, 2, 3];
array1.forEach((number, index) =>{
  array1.splice(index, 1)
   console.log(number);
});
```

forEach 中使用 **unshift** 方法：

```
// 输出 1，1, 1
const array1 = [1, 2, 3];
array1.forEach((number, index) =>{
  array1.unshift(number +  3)
   console.log(number);
});
```

**稀疏数组** forEach 遍历：

```
// 输出 3
const array1 = [, , 3];
array1.forEach((number, index) =>{
   console.log(number);
});
```

根据 ECMA 规范 实现 forEach：

```
Array.prototype.ForEach = function (callbackfn, thisArg) {
  if (this === null || this === undefined) {
    throw new TypeError("this 不能是 null 或者 undefined");
  }
  let O = this;
  let len = O.length;
  if (typeof callbackfn !== "function") {
    throw new TypeError("callback 不是函数");
  }
  for (let k = 0; k < len; k++) {
    if (k in O) {
      let kValue = O[k];
      callbackfn.call(thisArg, kValue, k, O);
    }
  }
};
```

### 20）Js 数组解构

场景一：

```
const list = ["a", "b", "c"];
cosnt[first, second] = list;
console.log(first, second); // a b
```

场景二：省略某个元素

```
const list = ["a", "b", "c"];
// 空出中间元素
cosnt[first, ,second] = list;
console.log(first, second); // a c
```

场景三：设置默认值

```
const list = ["a", "b"];
// 设置默认值
cosnt[first, ,second, third = 'c'] = list;
console.log(first, second, third); // a b c
```

场景四：嵌套数组解构

```
cosnt colors = ["red", ["green", "yellow"], "blue"];
cosnt [firstColor, [secondColor]] = colors;
console.log(firstColor, secondColor); // red, green
```

场景四：不定元素的解构赋值

```
cosnt colors = ["red", "green", "pink"];
cosnt [firstColor, ...otherColors] = colors;
console.log(firstColor);
console.log(otherColors);
```

### 21）NaN 和 Number.isNaN 有什么区别？

isNaN (): 先尝试转换为数字，若无法转换为数字，则返回 true，否则返回 false
Number.isNaN (): 直接检查一个值是否是 NaN。

### 22）void 0 和 undefined 有什么区别？开发中应该使用哪个？

**undefined** 不是关键字，可能作为变量被赋予别的值。

```
var undefined = 'ikun'
```

void 后跟 任何值 都会返回 undefined，可以安全的获取 undefined。

void 0 可以安全地获取 undefined。

### 23) 如何实现链式调用

### 24) 数组的索引会进行隐式类型转换吗？

JavaScript 数组本质上是特殊的对象，其索引在内部会被转换为字符串类型。因为 JavaScript 对象的属性名（键）只能是字符串或 Symbol 类型，所以当你使用非字符串类型的值作为数组索引时，会发生隐式类型转换，将其转换为字符串。

数字类型索引:

当使用数字作为数组索引时，会直接将数字转换为对应的字符串形式。

布尔类型索引:

布尔值 `true` 和 `false` 会分别被转换为字符串 `'true'` 和 `'false'`。

null 和 undefined 作为索引:

`null` 会被转换为字符串 `'null'`，而 `undefined` 会被转换为字符串 `'undefined'`。

对象作为索引:

当使用对象作为索引时，会调用对象的 `toString()` 方法将其转换为字符串。默认情况下，对象的 `toString()` 方法返回 `[object Object]`。

**对数组长度和遍历的影响**

**数组长度**：数组的 `length` 属性只与以非负整数（且小于 2^32 - 1）作为索引的元素有关。如果使用非数字字符串或转换后不是有效非负整数的字符串作为索引，不会影响数组的 `length` 属性。

```
const arr = [];
arr['a'] = 1;
arr['0'] = 2;
console.log(arr.length); // 输出: 1，因为 '0' 转换后是有效索引，而 'a' 不是
```

**遍历影响**：使用 `for...in` 循环可以遍历数组的所有可枚举属性（包括非数字索引），而 `for` 循环和 `forEach` 方法通常只遍历以有效非负整数作为索引的元素。



```
const arr = [];
arr["a"] = 1;
arr["0"] = 2;
for (let key in arr) {
  console.log(key, arr[key]);
  // 输出: 'a' 1  和  '1' 2
}
```

```
const arr = [];
arr["a"] = 1;
arr["0"] = 2;
for (let i = 0; i < arr.length; i++) {
    console.log(i, arr[i]); 
    // 输出: 0 2
}
```

```
const arr = [];
arr["a"] = 1;
arr["0"] = 2;
arr.forEach((val) => console.log(val)); 输出 2
```



### 25) 点操作符和方括号访问对象属性有什么区别？

点操作符, 静态属性访问:

- 通过点符号 (.) 访问的属性是静态的。

- 属性名是硬编码，且在编写代码时就已知。

- 不能使用变量作为属性名。
- 点表示法要求属性名必须是一个有效的JavaScript标识符。

方括号访问对象属性, 动态属性访问:

- 通过方括号访问的属性是动态的。

- 属性名可以在运行时计算得出的。我们可以使用变量、字符串字面量或表达式。

### 26) parseInt和Math.floor的区别是什么？

Math.floor():

**无论正负**, Math.floor 都只是简单地将一个数向下取整到最接近的整数。

它只接受**一个参数**: 你想要向下取整的数。

parseInt:

对于负数, 会**向上取整**到最接近的整数。

对于正数, 会**向下取整**到最接近的整数。

### 27) ["1","2","3"].map(parseInt)的输出结果是多少？

map 函数 完整的 参数形式: map((item, index, arr))

第一个参数 item : 当前遍历的元素。

第二个元素 index : 当前遍历的元素**下标**。

第三个元素 arr :  **数组本身**。

parseInt 函数:

语法格式: parseInt(string, radix)

radix 用于描述当前传入的字符串是 **几进制**

如果没传第二个参数 radix 或为 0  , 自动根据 string 的前缀判断是几进制。

### 28) object 和 map 有什么相同点和不同点？

创建方式的区别:

object: 一般通过字面量创建, 也可以通过构造函数创建。

map: 通过构造函数创建。

key 的类型不同:

object: 对象键是字符串, 数字, Symbol。

map: map 可以使用任何类型的值作为键，包括对象、函数、原始值等。

key 的顺序:

object：key 的顺序与插入顺序无关。

map：key 的书顺序就是插入顺序。

### 29) Object.freeze 和 const 有什么区别？各自用于什么场景？

Object.freeze () 和 const 的区别

Object.freeze () 返回的是一个不可变的对象。这就意味着我们不能添加，删除或更改对象的任何属性。

const 和 Object.freeze () 并不同，const 是防止变量重新分配，而 Object.freeze () 是使对象具有不可变性。

Object.freeze () 只能冻结当前对象, Object.freeze 仅能冻结对象的当前层级属性，换而言之，如果对象的某个属性本身也是一个对象，那么这个内部对象并不会被 Object.freeze 冻结。

## Vue 面试题

### 1）Diff 算法

虚拟dom

```
<div class="container">
<p class="item">思学堂</p>
<strong class="item">课程很精彩</strong>
</div>

let Vnode = {
    tagName: 'div',
    props: {'class': 'container', },
    children: [{
    tagName:'p', 
    props: {'class': 'item', },
    text:'思学堂'},
    {
    tagName: 'strong', 
    props: {'class': 'item', },
    text：'课程很精彩'
    }
}
```

diff算法目的是找出差异，最小化的更新视图。

**vue2 diff算法核心步骤**：

判断是否是同类标签， 若不是则直接替换

是同类标签，判断oldvnode和newvnode是否相等，相等直接返回，无需比较。

oldvnode和newvnode不相等：

oldvnode和newvnode都有文本节点，用新文本节点替换就文本节点

oldvnode没有子节点，newvnode有子节点，增加新的子节点

oldvnode有子节点，newvnode没有子节点，删除旧的子节点

oldvnode与newvnode都有子节点，需要使用首位指针双端diff算法， 核心逻辑在updateChildren方法中。

src/core/vdom/patch.js **updateChildren**函数核心逻辑：

①按照头头、尾尾、头尾、尾头的顺序依次比较，当比较成功后退出当前比较

②渲染结果以newVnode为准

③每次比较成功后start点和end点向中间靠拢

④当新旧节点中有一个start点跑到end点右侧时终止比较

⑤如果都匹配不到，则旧虚拟DOM key值去比对

新虚拟DOM的key值，如果key相同则复用，并移动到新虚拟DOM的位置

如果比对后 oldStart > oldEnd， 新虚拟节点元素有多余的元素，则会把多余的元素直接添加到真实的dom中。

如果比对后 newStart > newEnd， 新虚拟节点元素较少，则需要删除真实dom中多余的元素。

**vue3 diff算法核心步骤**：

packages/runtime-core/renderer.ts文件 patchChildren --> patchKeyedChildren 方法中。

patchKeyedChildren 方法逻辑：

① 预处理前置节点：从前(头头)比较新旧虚拟节点，节点相同则pathch打补丁更新

②预处理后置节点：从后(尾尾)比较新旧虚拟节点，节点相同则pathch打补丁更新

③处理仅有新增节点的情况， i > e1 && i <=e2

④处理仅有卸载节点的情况, i > e2 && i < e1的情况

⑤处理(新增 / 卸载 / 移动)混合复杂情况

建立新节点位置映射表：keyToNewIndexMap

建立新旧节点位置映射表：newIndexToOldIndexMap

## Axios 面试题

### 1）如何取消请求？

请求取消的场景：发送多个请求，返回结果顺序与请求发送顺序不一致导致页面显示错误的数据。

v0.22.0以后Axios 支持以 fetch API 方式—— [`AbortController`](https://developer.mozilla.org/en-US/docs/Web/API/AbortController) 取消请求

v0.22.0之前可以使用 *cancel token* 取消一个请求。

### 2）请求如何去重？

避免相同请求重复发送

