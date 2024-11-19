/** 并发任务控制 问题1
 * 完成 asyncOnce 函数， 函数接受一个异步函数作为参数
 * 返回一个新的函数，该函数在短时间内多次调用时，只会执行一次
 */

function asyncOnce(asyncFn) {
  const map = {};
  return (...args) => {
    return new Promise((resolve, reject) => {
      const key = JSON.stringify(args);
      if (!map[key]) {
        map[key] = {
          resolves: [],
          rejects: [],
          isPending: false,
        };
      }
      const state = map[key];
      state.resolves.push(resolve);
      state.rejects.push(reject);
      if (state.isPending) return;
      state.isPending = true;
      asyncFn(args)
        .then((res) => {
          state.resolves.forEach((resolve) => resolve(res));
        })
        .catch((err) => {
          state.rejects.forEach((reject) => reject(err));
        })
        .finally(() => {
          map[key] = null;
        });
    });
  };
}

/** 并发任务控制 问题2
 * 同一时间只能执行两个任务，超过两个任务需要等待
 *
 * */
function timeout(time) {
  return new Promise((resolve) => setTimeout(resolve, time));
}

class SuperClass {
  constructor(parallelCount = 2) {
    this.parallelCount = parallelCount;
    this.tasks = [];
    this.runningCount = 0;
  }
  add(task) {
    return new Promise((resolve, reject) => {
      this.tasks.push({
        task,
        resolve,
        reject,
      });
      this.#run();
    });
  }

  // 执行任务
  async #run() {
    while (this.runningCount < this.parallelCount && this.tasks.length > 0) {
      const { task, resolve, reject } = this.tasks.shift();
      this.runningCount++;
      task()
        .then(resolve, reject)
        .finally(() => {
          this.runningCount--;
          this.#run();
        });
    }
  }
}
const superTask = new SuperClass(2);
function addTask(time, name) {
  superTask.add(() => timeout(time)).then(() => console.log(`任务${name}完成`));
}
