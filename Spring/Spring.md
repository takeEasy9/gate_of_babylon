# Spring

[TOC]



## 1) Spring Bean生命周期

**`Bean`定义**： 通过`loadBeanDefinitions()`方法加载Bean定义放到`beanDefinitionMap`中。

实例化前扩展点：

- `BeanFactoryPostProcessor.postProcessBeanFactory()`：在 `Spring` 容器实例化任何 `Bean` 之前修改 `Bean` 的定义信息。可以在 `Bean` 实例化之前修改 `Bean` 的属性、添加或移除 `Bean` 等操作。
- `FactoryBean.getObject()`：`getObject()` 方法是用来创建 `Bean` 实例的，它在 `Spring` 容器需要创建 `Bean` 时被调用。通常，它会在 `Bean` 实例化之前被调用

**Bean实例化**：

实例化之后、初始化前：

Bean属性填充(依赖注入)：`@Autowired` 注解的 setter 方法、构造函数、字段注入等方式将依赖注入到 Bean 中。

`ApplicationContextAware`等接口回调

**Bean初始化**：

初始化前，`BeanPostProcessor.postProcessBeforeInitialization()`

执行 `@PostConstruct`、`InitializingBean.afterPropertiesSet()`、`initMethod`、

初始化后，`BeanPostProcessor.postProcessBeforeInitialization()`

**使用Bean**：

销毁Bean前扩展点：

`@PreDestroy`、`DisposableBean.destroy`、`destroy-method`

**销毁 Bean**：Spring容器关闭

**Spring Bean 相关问题**：

1.1) **`SpringBean`生命周期实际应用 ？**

答：间接使用如@Transactional AOP生成代理类。

1.2) **`Spring Bean`是否是线程安全的 ？**

答：常见的八股文式答：无状态的单例Bean和原型Bean是线程安全的。有状态的单例Bean是线程不安全的，而有状态的原型Bean是线程安全的，原因是原型Bean每次请求都会创建一个新的Bean实例。

不管是单例Bean还是原型Bean，只要没有状态（属性）被共享，必然是线程安全的。

不管是不是在Spring框架里，只要某个Java对象中的状态被多个线程修改，就会有线程安全问题，和单例还是原型没有任何关系。

解决线程安全问题常用手段如下：

- 加锁（串行化）；
- 原子操作类（例如AtomicInteger）CAS （串行化）；
- 线程安全的集合类（串行化）；
- 不可变对象（不能修改必然安全）；
- ThreadLocal（各玩各的）。

1.3) **Spring单例Bean正确引用一个Prototype的Bean的几种方式**

- 修改原型 Bean 的代理模式，@Scope 的属性 proxyMode 使用 ScopedProxyMode.TARGET_CLASS。
- 注入原型 Bean 时使用 ObjectFactory。
- 在默认返回 Null 值的方法上使用 @LookUp 注解。

## 2) Spring 启动流程

**2.1) 服务构建**

创建 SpringApplication 对象。

- 在 SpringApplication 构造方法内记录资源加载器、主方法类。
- 通过对应的类是否存在来确定 web 服务类型(SERVLET、REACTIVE、NONE)。
- 加载初始化类，读取所有 META-INF/spring.factories (SpringBoot 2.7之前) 文件中的启动注册初始化器(BootstrapRegistryInitializer)、上下文初始化器(ApplicationContextInitializer)、应用监听器(ApplicationListener)配置。

**2.2) 环境准备**

加载环境配置，为后续容器创建做准备。

- 创建 DefaultBootstrapContext 对象，逐一调用服务构建阶段加载的 启动注册初始化器(BootstrapRegistryInitializer)的initialize方法。
- 将 java.awt.headless 设置为 true，表示缺少显示、键盘等输入设备也可以正常启动。
- 启动 运行监听器 (SpringApplicationRunListeners), 同时发布启动事件， 获取并加载 spring.factories 配置文件中的 EventPublishingRunListener。
- 通过 prepareEnvironment 方法组装启动参数，通过不同的Web服务类型会构造不同的环境，构造之后会加载**系统环境变量**、**JVM系统属性**、配置信息，将这些信息加载到 propertySources的内存集合中。通过 configureEnvironment 方法将启动时传入的环境参数args进行设置。发布环境准备完成事件。
- 将 spring.beaninfo.ignore 设置为 true，表示不加 Bean 的元数据信息。然后打印 banner 图。

**2.3) 容器创建**

创建容器(应用上下文)。

- 通过 createApplicationContext 方法根据服务类型创建容器(ConfigurableApplicationContext, 默认 servlet 类型对应的容器为AnnotationConfigServletWebServerApplicationContext)，在这个过程中会构造诸如存放和生产 Bean 实例的 **Bean 工厂(DefaultListableBeanFactory)**、用来解析@Component、@ComponentScan等注解配置类后处理器(ConfigurationClassPostProcessor)、用来解析@Autowired、@Value、@Inject等注解的 AutowiredAnnotationBeanPostProcessor。
- 通过 prepareContext 方法对容器中的部分属性进行初始化，先使用 postProcessApplicationContext 方法设置**Bean名称生成器**、**资源加载器**、**类型转换器**等。接着执行之前加载的上下文初始化器(ApplicationContextInitializer)(容器 ID、警告日志处理、日志监听都是在这里实现的)，发布**容器准备完成**事件，然后为容器注册**启动参数**、**Banner**、**Bean 引用策略**、**懒加载策略**。通过 Bean 定义加载器将包括启动类在内的资源加载到 Bean 定义池(BeanDefinitionMap)中，发布**容器加载完成**事件。

**2.4) 填充容器**

- prepareRefresh: 通过 prepareRefresh 方法在已有的**系统环境**基础上准备servlet相关的的环境(Environment)。
- obtainFreshBeanFactory：一般该方法不做任何处理，SpringBoot 中在容器创建阶段 BeanFactory 已构造好了。
- prepareBeanFactory：获取容器同时在使用 BeanFactory 之前进行一些准备工作，主要准备**类加载器(BeanClassLoader)**、**表达式解析器(BeanExpressionResolver)**、**配置文件处理器(PropertyEditorRegistrar)**等系统处理器、用来解析 Aware 接口的ApplicationContextAwareProcessor、用来处理自定义监听器注册和销毁的 ApplicationListennerDetector Bean后置处理器(BeanPostProcessor)， 同时会注册一些特殊 Bean 和系统级 Bean。
- postProcessBeanFactory：对 BeanFactory 进行额外设置或修改，定义 servlet 相关作用域，注册与 servlet 相关的一些特殊 Bean。
- invokeBeanFactoryPostProcessors：执行在容器创建阶段注册的 **BeanFactory后置处理器(BeanFactoryPostProcessors)**，其中最主要的就是用来加载所有Bean定义的 配置处理器 (ConfigurationClassPostProcessor), 检索指定的 Bean 扫描路径， 然后通过 Bean 扫描器(ClassPathBeanDefinitionScanner)中的 doScan 方法加载每个类放入Bean定义池中， 同样也会扫描所有加了 @Bean、@Import等注解的类和方法。
- registerBeanPostProcessors： 注册所有的Bean后置处理器， 并按指定的 Order 进行排序， 然后放入Bean后置处理器池(beanPostProcessors)中。
- initMessageSource：初始化用于国际化的 messageSource Bean。
- initApplicationEventMulticaster：用于自定义广播事件的 applicationEventMulticaster Bean。
- onRefresh：构造并启动Web服务器。
- registerListeners：查找并注册所有的监听器 Bean。
- finishBeanFactoryInitialization：创建所有的 Bean(Spring Bean 生命周期)。
- finishRefresh：构造并注册**生命周期管理器(LifecycleProcessor)**，同时调用所有实现了生命周期接口的 Bean 方法中的 start 方法。发布**容器刷新完成**事件。

- 回调 自定义实现的 Runner 接口。

## 3）Spring AOP 原理

Spring AOP 依赖 面向切面编程理念的AspectJ 框架，AspectJ能够在已有方法、属性、代码块的基础上对功能进行增强， Spring AOP 只使用AspectJ 框架对**方法**进行增强。

Spring AOP 常见的使用场景：

- 事务处理， 如 @Transactional 。
- 统一异常处理。
- 缓存层。
- 权限控制。
- 性能统计，日志。

Sping AOP Advice：

- @Around：对方法进行包裹。
- @Before：在方法之前。
- @AfterReturning：在方法正常返回后。
- @AfterThrowing：在方法异常返回后。
- @After：在方法之后， 等价于 @AfterReturning 加上 @AfterThrowing。

多个 Advice 执行顺序：

@Around &rarr; @Before &rarr; @AfterReturning(@AfterThrowing) &rarr; @After &rarr; @Around

Spring AOP 使用到了代理模式，代理模式可以分为静态代理和动态代理。

静态代理：在代码运行前通过修改class文件来完成代理，功能强大，效率极高，但复杂度较高。

静态代理实现方式：

- 编译前
- 编译后
- 加载 class 时

动态代理：在代码运行时进行代理，功能受限且有额外的性能开销，但使用相对简单。

AspectJ使用静态代理模式，通过AspectJ编译器重新编译生成一个新的代理类，Spring AOP 使用动态代理模式，在代码运行时生成代理类的子类, 在子类中重写被代理的方法，因此要求被代理方法的可见性修饰符是 **public**，且方法不能被 **static** 和 **final**。

Spring AOP 通过 DefaultAdvisorAutoProxyCreator Bean 后置处理器对方法进行增强， 在每一个 Bean 初始化之后都会调用 postProcessAfterInitialization 方法， 在这个方法里会为需要使用 AOP 的 Bean创建代理对象。

## 4）@Transactional 注解

4.1）@Tranctional 注解**事务传播机制**

事务传播机制可以分为三类，支持当前事务，不支持当前事务，嵌套事务。

支持当前事务：

Propagation.REQUIRED：需要有，如果当前方法没有事务，新建一个事务，如果已经存在一个事务中，则加入到这个事务中。

Propagation.SUPPORTS：可以有，支持当前事务，如果当前没有事务，就以非事务的方式运行。

Propagation.MANDATORY：强制有，使用当前事务，如果当前没有事务，就抛出异常。

不支持当前事务：

Propagation.REQUIRES_NEW：新建事务执行，如果当前存在事务，把当前事务挂起。

Propagation.NOT_SUPPORTED：以非事务的方式执行操作，如果当前存在事务，把当前事务挂起。

Propagation.NEVER：以非事务方式执行，如果当前存在事务，则抛出异常。

Propagation.REQUIRES_NEW 传播机制底层实现：所谓的**事务挂起**，就是开启一个新 connection，并开启新事务。那么这两个事务在两个 connection 中，必然不会有任何的相互影响。

嵌套事务：

Propagation.NESTED：如果当前存在事务，则在嵌套事务内执行，如果当前没有事务，则执行与 Propagation.REQUIRED 类似的操作。

嵌套事务效果：在已经处在的事务中开启一个子事务，这个子事务可以单独回滚，但不能单独提交。外部事务提交时，会把没有回滚的子事务一起提交。外部事务回滚时，会回滚所有操作。

嵌套事务的实现方式：

如果数据库支持 SAVEPOINT 方式，则使用 SAVEPOINT ，否则使用 JTA(JtaTransactionManager) 方式。JtaTransactionManager 完全创建了新事务，然后基于TransactionSynchronizationManager 的方式，来协调这些事务共同提交/回滚。

