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

