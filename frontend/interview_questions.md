## 前端常见面试问题

### JS

1 ) 手写Promise

Promises/A+: Promise 规范 [Link &rarr;]([Promises/A+中文网 (promisesaplus.com.cn)](https://promisesaplus.com.cn/))，[代码实现](js/promise.html)

[参考实现1]([javascript - 手写一个Promise/A+,完美通过官方872个测试用例 - 进击的大前端 - SegmentFault 思否](https://segmentfault.com/a/1190000023157856))

[参考实现2]([手写Promise第一章_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV19SmjY8EFU/?spm_id_from=333.337.search-card.all.click&vd_source=a44de6033b8c062af031b64fe746f310))

2）async 与 await

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

3）如何消除异步的传递性

React 代数效应

4）axios 相关面试题

4.1 如何取消请求？

请求取消的场景：发送多个请求，返回结果顺序与请求发送顺序不一致导致页面显示错误的数据。

v0.22.0以后Axios 支持以 fetch API 方式—— [`AbortController`](https://developer.mozilla.org/en-US/docs/Web/API/AbortController) 取消请求

v0.22.0之前可以使用 *cancel token* 取消一个请求。

4.2 请求如何去重？

避免相同请求重复发送



5） 数字精度相关题

数字的存储、运算、显示都可能是不精确的。

5.1 toFixed 函数

1.55.toFixed(1) = 1.6

3.55.toFixed(1) = 3.5

decimal.js 库解决js中数字不精确问题，存储、运算都以字符串形式。

银行家算法： 1234 舍去， 6789入， 5看情况。

5.2 手写数字字符串运算，解决大整数相加与浮点数运算精度问题



6）对象数组去重？

递归比较对象属性值

7）手写发布订阅模式

[发布订阅模式实现 &rarr;](subscrbePattern.js)

8）JS 解构

```
const { age, address } = person // 最基础的解构
const { age = 20, address = "美国" } = person // 解构时设置默认值
const { age = 20, address： addr = "美国" } = person // 解构时重命名
```



**9）js中的隐式类型转换**

 js == 隐式类型转换规则

1. 如果两个值的类型相同，则直接进行比较，比如：

- 两个字符串根据其字符进行比较。

- 两个数字进行数值比较。

2.如果一个值是null另一个值是 undefined,则直接返回true。

3.如果一个值是数字，另一个值是字符串：

- 尝试将字符串转换为数字，然后比较。

4. 如果其中一个值是布尔值:

- 如果为 true，转换为数字 1
- 如果为 false，转换为数字 0
- 然后在进行比较

5. 如果一个值是对象，另一个值是数字或字符串或布尔值：尝试转换对象为其原始值。然后比较。

先尝试调用对象的valueOf方法

10） 前端框架diff算法

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

**11）JS 相关区别**

11.1 null 与 undefine 的区别

null: no object

undefined: no value

变量引用存在但本身指向的值就是null

undefined指的是这个引用本身不存在

11.2  Object、object、{}的区别

Object：支持所有的引用类型与原始类型, 声明为Object类型的对象变量不能再添加属性。

object：非原始类型的，常用于泛型约束，用于表示引用类型。

{}： 空对象，与Object等价，该类型的变量可以赋值任何类型， 缺点与Object相同。

11.3 typescript 中 any、unknown、void、never类型的区别

any: 任何类型，任何类型的变量都可赋值any类型的变量，any类型的变量也可赋值类任何其他类型的变量。

unknown：比any更加严格，unknown类型的变量只能赋值给unknown或any类型。

void: 常用于函数返回类型，表示该函数无返回值。

never: 不存在的类型，比如交叉类型 type A = number & string

**12） ES 模块和 CommonJS 模块化方案有什么区别？**

ES（ECMAScript）： ES 模块化是由 ECMAScript 标准规定的，属于 JavaScript 语言本身的一部分。它在 ES6（ECMAScript 2015）中被引入，并已成为 JavaScript 的标准模块化方案。

CommonJS：CommonJS 是 Node.js 中使用的模块化规范，最初是为了解决 JavaScript 在服务器端的模块化问题而创建的。虽然它不是 JavaScript 语言的一部分，但在 Node.js 生态系统中得到了广泛应用。 - **语法和特性：**

ES 模块：ES 模块使用 import 和 export 关键字来导入和导出模块。它支持静态解析，模块加载是异步的，模块的引用是动态的。

CommonJS：CommonJS 使用 require() 函数来导入模块，使用 module.exports 或 exports 来导出模块。它是同步加载的，模块的引用是静态的。

- **用途和环境：**

ES 模块：ES 模块广泛应用于现代的 Web 开发中，可以在浏览器环境和 Node.js 环境中使用。

CommonJS：CommonJS 主要用于 Node.js 环境，用于组织服务器端的 JavaScript 代码，例如构建 web 服务器、文件系统操作等。

- **动态性：**

ES 模块：ES 模块的静态解析意味着模块的依赖关系在代码执行前已经确定，因此它不支持动态导入。

CommonJS：CommonJS 支持动态导入，可以在运行时根据条件加载模块。

**4. ES 模块中 export 出去的对象能被修改么？**

在 ES 模块中，export 出去的对象默认是只读的，不能被修改。当一个对象被导出后，在其他模块中引入该对象时，只能读取其属性和方法，而不能修改它们。

