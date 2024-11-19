// ES 模块和 CommonJS 模块化方案有什么区别？

// CommonJS require函数伪代码，逻辑大体相同
// 在CommonJS中，this, module.exports, exports最初都指向同一个空对象
// require函数返回的是module.exports指向的对象
function require(modulePath) {
  // 1.根据传递的模块路径, 得到模块完整的绝对路径
  var moduleId = getModuleId(modulePath);
  // 2.判断模块是否加载过, 如果加载过, 直接返回模块的 exports 对象
  if (caches[moduleId]) {
    return caches[moduleId].exports;
  }
  //3. 真正运行模块代码的辅助函数
  function _require(exports, require, module, __filename, __dirname) {
    // 目标模块代码在这里
  }
  // 4. 准备并运行辅助函数
  var module = {
    exports: {},
  };
  var exports = module.exports;
  // 得到模块文件的绝对路径
  var __filename = moduleId;
  // 得到模块文件所在目录绝对路径
  var __dirname = getDirname(__filename);
  _require.call(exports, exports, require, module, __filename, __dirname);
  // 5. 将模块的 exports 对象缓存起来
  caches[moduleId] = module.exports;
  // 6. 返回模块的 exports 对象
  return module.exports;
}

// CommonJS 模块化方案面试题, 在其他文件导入时获取到的对象是 {d: 4}
this.a = 1;
exports.b = 2;
exports = {
  c: 3,
};
module.exports = {
  d: 4,
};
exports.e = 5;
this.f = 6;
