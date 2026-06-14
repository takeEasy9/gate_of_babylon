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

多个 Advice 执行顺序(>=Spring 5.0)：

AOP 执行可以抽象为一下代码：

```
public class Proxy {
	public void method() {
	// Before
	  try {
	    initialMethod()
	    // AfterReturning
	  } catch (Exception e) {
	  // AfterThrowing
	  } finally {
	  	// After
	  }
	}
}
```

业务代码正常执行：

@Around 前置代码

@Before

业务代码

 @AfterReturning

@After

@Around 后置代码

业务代码抛出异常：

@Around 前置代码

@Before

业务代码

 @AfterThrowing

@After

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

## 5）循环依赖

Spring 使用三级缓存机制通过对象已经实例化还未初始化的中间态解决循环依赖的问题。

Spring 三级缓存：

- 一级（singletonObjects）：存储已经初始化好的对象。
- 二级（earlySingletonObjects）： 存储已经完成实例化但还未完成初始化的对象。
- 三级（singletonFactories ）：存储对象的对象工厂，这个对象工厂用于创建或返回一个单例的对象，而且会判断 bean 是否需要 AOP。

普通不存在循环依赖 bean 创建过程：

对象 beanA 在初始化过程中依赖于 对象 beanB， Spring 会把 对象 beanA 放入**二级缓存**，然后去创建 对象 beanB， beanB 初始化完成之后放入**一级缓存**，然后再注入到对象 beanA 里， 最后把对象 beanA 从**二级缓存**删除，放入一级缓存。

Spring 解决循环依赖的过程：

AbstractAutowireCapableBeanFactory 类在创建对象 beanA的过程中，判断下面条件是否成立，若成立会把  beanA 的对象工厂放入**三级缓存**，

```
boolean earlySingletonExposure = mbd.isSingleton() && this.allowCircularReferences && this.isSingletonCurrentlyInCreation(beanName);
```

DefaultSingletonBeanRegistry -> getSingleton 方法：

初始化对象 对象 beanB 时能从**三级缓存**获取到对象 BeanA，如果 BeanA需要代理，对象工厂会返回 BeanA 的代理对象， 如果不需要代理则返回对象本身， 拿到对象 BeanA之后， Spring 会删除**三级缓存**中的 BeanA 对象工厂， 将对象  beanA 放入**二级缓存**， 然后分别初始化对象 BeanB 和 BeanA。

DefaultSingletonBeanRegistry -> addSingleton方法：

初始化完成，将对象 BeanB 和 BeanA 加入**一级缓存**()，这一步会将**三级缓存**中的对象 BeanB 和**二级缓存**中的 BeanA 删除。

Spring Boot 2.6 版本引入以下配置

```
spring:
  main:
    allow-circular-references: true // 默认 false，
```

在 Spring Boot 2.6 之前，Spring 默认支持单例 Bean 的循环引用，依靠三级缓存机制来解决此类问题。但在 Spring Boot 2.6 中，出于安全和可维护性等方面的考虑，默认行为发生了改变，**默认禁止**了单例 Bean 的循环引用。为了让用户可以根据自身需求恢复之前允许循环引用的行为。

Spring 如何 判断 bean 之间是否存在**循环依赖**？

在创建 Bean 的过程中，当需要获取依赖的 Bean 时，会通过`DefaultSingletonBeanRegistry` 类`isSingletonCurrentlyInCreation(beanName)` 方法检查该依赖 Bean 是否正在创建中。如果是，则说明出现了循环依赖。

## 6）Spring 应用优雅停机

优雅停机是指在应用停止之前，要先完成所有正在进行的任务，释放资源，然后在安全退出，而不是直接强制终止进程。

为什么需要优雅停机？

如果直接 kill -9 pid 或直接杀死进程，可能有正在处理的请求或正在等待排队处理的请求，线程池正在执行你的任务，MQ正在消费消息，定时任务正在执行对账, S数据库链接正在连接数据库处理 SQL 语句， 获取分布式锁的方法正在执行， 此时贸然终止进程，可能会出现脏数据或者分布式锁没有及时释放。

### 6.1）Spring MVC 等待未处理完的请求

```
# SpringBoot 配置
server
  shutdown: "graceful"
spring:
  lifecycle:
    timeout-per-shutdown-phase: "20s"
```

### 6.2）线程池优雅关闭

### 6.3）Spring Cloud 优雅关闭

- 停止接受新请求（server.shutdown=graceful)。
- 从注册中心摘除服务（比如 Eureka、 Nacos、 Consul）。
- 处理进行中的请求（等待请求处理完后再关闭）。
- 关闭异步任务、线程池（确保后台任务执行完）。
- 确保消息队列消费者正常退出（Kafka、RabbitMQ)。
- 其他资源释放（数据库连接、缓存等）。

Spring Cloud 内部使用的线程池通常包括：

- Web 服务器线程池 （Tomcat/Jetty）：自动关闭。
- Ribbon 线程池（负载均衡）：Spring Cloud 2020 之后默认用 Spring 负载均衡，不需要关闭。
- Hystrix 线程池（熔断器，Spring Cloud 2020 之后放弃）。
- Feign 线程池（如果 Feign 开启了 @Async，则需要手动关闭）。
- Spring Cloud Gateway 线程池（如果有 自定义的 Netty 线程池，需要关闭）。
- 

6.4）关闭Spring应用的正确方式

**Shell 脚本**

```
kill -15 pid #发送 SIGTERM, 触发 SpringBoot 的优雅关闭逻辑
```

**Docker**

```
docker stop --time=30 my-spring-app
```

**Docker Compose 方式**

```
docker-compose stop -t 30
```

## 7) Spring 经典工具类

### 7.1) StringUtils

判空、转数组、前后缀判断

```
public static void stringUtils(){
    System.out.println(StringUtils.isEmpty(str: null));  // true, 不推荐使用了
    System.out.println(StringUtils.isEmpty(str: ""));   // true, 不推荐使用了
    System.out.println(StringUtils.hasText(str: " ")); // false
    System.out.println(StringUtils.hasText(str: "Shark")); // true

    //分割数组, 这里用逗号 ,
    System.out.println(StringUtils.tokenizeToStringArray(str: "1,2,3", delimiters: ",")); // ["1", "2", "3"]

    //直接逗号, 分割
    System.out.println(StringUtils.commaDelimitedListToStringArray("1,2,3")); // ["1", "2", "3"]
    System.out.println(StringUtils.commaDelimitedListToSet(str: "1,2,2,3")); // ["1", "2", "3"]

    //字符串前后缀判断
    System.out.println(StringUtils.startsWithIgnoreCase(str: "Hello", prefix: "he")); // true

    //判断后缀
    System.out.println(StringUtils.endsWithIgnoreCase(str: "Hello", suffix: "LO")); // true

    //去掉空白字符, 包含tab , 空格
    System.out.println(StringUtils.trimAllWhitespace(str: " a b \t c ")); // true

    //去除左侧 trimLeadingWhitespace(String str)
    //去除右侧 trimTrailingWhitespace(String str)

    //规范化路径, 移出重复的.. /
    System.out.println(StringUtils.cleanPath("a/b/c/../c")); // "/a/b/c"

    //替换
    System.out.println(StringUtils.replace(inString: "hello world", oldPattern: "world", newPattern: "Java"));
}
```



### 7.2) CollectionUtils

```
public static void collectionUtils() {
    // 判断NPE
    List<String> list = null;
    if (CollectionUtils.isEmpty(list)) {
        System.out.println("list is empty or null");
    }

    // 判断两个集合是否至少包含一个元素相同
    List<String> roles = List.of("USER", "ADMIN");
    List<String> require = List.of("ADMIN", "ROOT");
    boolean has = CollectionUtils.containsAny(roles, require);
    System.out.println(has); // true

    // 查找第一个匹配的元素
    List<String> allowed = List.of("ADMIN", "ROOT");
    String match = CollectionUtils.findFirstMatch(roles, allowed);
    System.out.println(match); // ADMIN

    // 把数组内容加入集合
    String[] arr = {"a", "b"};
    List<String> list2 = new ArrayList<>();
    CollectionUtils.mergeArrayIntoCollection(arr, list2);
    System.out.println(list2); // [a, b]

    // 把 Properties 转为 Map
    Properties props = new Properties();
    props.setProperty("env", "prod");
    props.setProperty("db", "mysql");
    Map<String, Object> map = new HashMap<>();
    CollectionUtils.mergePropertiesIntoMap(props, map);
    System.out.println(map);

    // 数组变 List
    String[] arr2 = {"x", "y"};
    List<?> objects = CollectionUtils.arrayToList(arr2);
    System.out.println(objects);
}
```



### 7.3) SystemPropertyUtils

```
public static void systemPropertyUtils() {
    // 获取启动JVM -D参数
    // java -Dapp.env=dev -jar app.jar
    // String env = SystemPropertyUtils.resolvePlaceholders("${app.env}");

    // 读取系统属性, 若用户没配置, 自带默认值 ${user.home}/logs
    String logDir = SystemPropertyUtils.resolvePlaceholders(
        "${app.log.dir:${user.home}/logs}"
    );
    System.out.println(logDir);

    // 解析文件路径
    String path = SystemPropertyUtils.resolvePlaceholders(
        "${user.home}/config/${app.name:demo}"
    );
    System.out.println(path);

    // 简单的模板替换
    String text = "Hello, ${user.name:unknown}!";
    String resolved = SystemPropertyUtils.resolvePlaceholders(text);
    System.out.println(resolved);

    System.out.println(SystemPropertyUtils.resolvePlaceholders("${java.home}"));
}
```

### 7.4) ReflectionUtils

 Spring 提供的 `org.springframework.util.ReflectionUtils` 工具类，封装了 Java 原生反射的样板代码，简化了字段、方法的查找与调用。

```
public static void reflectionUtils() {
    class User {
        private String name;

        private void sayHello(String name) {
            System.out.println("Hello, " + name);
        }
    }

    User user = new User();

    // 设置字段值
    Field field = ReflectionUtils.findField(User.class, "name");
    ReflectionUtils.makeAccessible(field); // 打破 private 限制
    ReflectionUtils.setField(field, user, "Shark");
    System.out.println(user.name); // Shark

    // 方法调用
    Method method = ReflectionUtils.findMethod(User.class, "sayHello", String.class);
    ReflectionUtils.makeAccessible(method);
    ReflectionUtils.invokeMethod(method, user, "Shark");
}
```

### 7.5 ClassUtils

Spring 提供的 `org.springframework.util.ClassUtils` 工具类，封装了类加载、类信息获取、类型判断等常用操作，简化了与 `java.lang.Class` 相关的样板代码。

```
public static void classUtils() throws ClassNotFoundException {
    // 加载类，支持数组、原始类型、内部类
    Class<?> clazz = ClassUtils.forName("java.util.ArrayList", ClassUtils.getDefaultClassLoader());
    System.out.println(clazz); // class java.util.ArrayList

    // 判断依赖是否存在，比如自定义的starter，可以判断完之后，再进行相应的初始化等操作
    if (ClassUtils.isPresent("com.fasterxml.jackson.databind.ObjectMapper", ClassUtils.getDefaultClassLoader())) {
        // 自动启用 Jackson 相关逻辑
        System.out.println("自动启用 Jackson 相关逻辑");
    }

    // 获取类名称，不带包名
    String name = ClassUtils.getShortName(java.util.ArrayList.class);
    System.out.println(name); // ArrayList

    // 获取包+类名的全称
    String full = ClassUtils.getQualifiedName(ArrayList.class);
    System.out.println(full); // java.util.ArrayList

    // 获取包名
    String pkg = ClassUtils.getPackageName(ArrayList.class); // java.util
    System.out.println(pkg);

    // 判断类型是否可赋值，支持原始类型与包装类型
    boolean assignable = ClassUtils.isAssignable(int.class, Integer.class); // true
    System.out.println(assignable);

    // 获取真实的Class，而不是代理的
    @Service
    class MyService {}

    MyService proxy = proxyObject; // CGLIB 代理对象
    Class<?> userClass = ClassUtils.getUserClass(proxy);
    System.out.println(userClass); // MyService.class, 而不是代理类
}
```

### 7.6) BeanUtils

Spring 提供的 `org.springframework.beans.BeanUtils`，专门用于 JavaBean 的实例化和属性拷贝，和 Apache Commons BeanUtils 功能类似但性能更优。

```
public static void beanUtils() throws NoSuchMethodException {
    @Data
    // 实例化类
    class User {
        private String name;
        private int age;

        public User(String name, int age) {
            this.name = name;
            this.age = age;
        }

        public User() {}
    }

    // 默认构造
    User user = BeanUtils.instantiateClass(User.class);
    System.out.println(user); // User 对象，默认构造函数创建

    // 参数构造
    Constructor<User> ctor = User.class.getConstructor(String.class, int.class);
    User user2 = BeanUtils.instantiateClass(ctor, "Shark", 25);
    System.out.println(user2);

    // 属性拷贝（浅拷贝）
    User dto = new User();
    BeanUtils.copyProperties(user2, dto);
    System.out.println(dto.getName()); // Shark
}
```

### 7.7) FileCopyUtils

```

```

### 7.8) ResourceUtils

 Spring 提供的 `org.springframework.util.ResourceUtils`，用于简化对各种类型资源（classpath、文件、URL、jar 包内资源）的读取与判断。

```
//ResourceUtils 资源操作工具类
public static void resourceUtils() throws IOException {
    //获取classpath下的资源文件
    File file = ResourceUtils.getFile("classpath:application.properties");
    System.out.println(file.exists());

    Properties props = new Properties();
    props.load(new FileInputStream(file));

    //从URL获取
    URL url = new URL("file:/data/test.txt");
    File file1 = ResourceUtils.getFile(url);

    //判断url类型, classpath:, file:, https:, ftp, jar:等
    boolean isClasspath = ResourceUtils.isUrl("classpath:/config.yaml"); // true
    boolean isHttp = ResourceUtils.isUrl("http://example.com/file.txt"); // true

    URL url2 = new URL("jar:file:/app.jar!/application.properties");
    if (ResourceUtils.isJarURL(url2)) {
        // 用 JarURLConnection 读取
    }
}
```

### 7.9) StreamUtils

 **Spring 提供的 `org.springframework.util.StreamUtils`**，是专门用来简化 IO 流操作的工具类，避免手动写循环读取流的样板代码。

```
public void streamUtils(HttpServletRequest request, HttpServletResponse response) throws IOException {
    // InputStream → byte[]
    InputStream in = new ByteArrayInputStream("Hello Spring".getBytes());
    byte[] data = StreamUtils.copyToByteArray(in);
    System.out.println(new String(data)); // Hello Spring

    // InputStream → OutputStream
    InputStream ins = new ByteArrayInputStream("Hello Spring".getBytes());
    ByteArrayOutputStream out = new ByteArrayOutputStream();
    StreamUtils.copy(ins, out);
    System.out.println(out.toString()); // Hello Spring

    // Copy String to output stream
    StreamUtils.copy("Shark", StandardCharsets.UTF_8, out);

    // Copy stream to a string
    String s = StreamUtils.copyToString(ins, StandardCharsets.UTF_8);

    // 请求响应
    byte[] body = StreamUtils.copyToByteArray(request.getInputStream());
    response.getOutputStream().write(body);

    // 读取资源获取内容
    InputStream inss = getClass().getResourceAsStream("/config.json");
    String content = StreamUtils.copyToString(inss, StandardCharsets.UTF_8);

    // MultipartFile 处理
    // byte[] datas = StreamUtils.copyToByteArray(file.getInputStream());
}
```

### 7.10) FileSystemUtils

 **Spring 提供的 `org.springframework.util.FileSystemUtils`**，专门用于简化文件系统操作，提供递归删除、复制等便捷方法。

```
public static void fileSystemUtils() throws IOException {
    // 结合 Files.createTempDirectory 使用
    Path tmp = Files.createTempDirectory("demo");
    FileSystemUtils.deleteRecursively(tmp.toFile());

    // 递归删除但保留根目录
    File dir = new File("logs");
    for (File file : Objects.requireNonNull(dir.listFiles())) {
        FileSystemUtils.deleteRecursively(file);
    }

    // 递归复制
    FileSystemUtils.copyRecursively(new File("source"), new File("target"));
}
```

### 7.11) UriComponentsBuilder

Spring 提供的 `org.springframework.web.util.UriComponentsBuilder`，是构建和编码 URI 的流式构建器，支持路径变量、查询参数、URL 编码等功能。

```
// url构建UriComponentsBuilder
public static void urlComponentsBuilders() {
    URI uri = UriComponentsBuilder.fromHttpUrl("http://shark.com")
            .path("/goods/{id}")
            .queryParam("category", "music")
            .build("122");

    // Result: http://shark.com/goods/122?category=music
}
```

### 7.12) ObjectUtils

 Spring 提供的 `org.springframework.util.ObjectUtils`，是一个通用的对象工具类，最常用的就是 `isEmpty` 方法，支持多种类型的 “空值” 判断。

```
// ObjectUtils
public static void objectUtils() {
    // 判断是否为空，几乎所有的对象，数组，集合，都可以用 ObjectUtils 来判断
    ObjectUtils.isEmpty(new ArrayList<>());
    ObjectUtils.isEmpty((Object[]) null);
    System.out.println(ObjectUtils.isEmpty(" "));
}
```

### 7.13) NumberUtils

 Spring 提供的 `org.springframework.util.NumberUtils`，专门用于字符串与数字类型之间的解析和转换，支持多种数字类型及进制。

```
// NumberUtils
public static void NumberUtils() {
    // String -> number
    // · 支持 Byte、Short、Integer、Long、Float、Double
    // · 如果字符串无法解析，会抛 IllegalArgumentException
    Integer i = NumberUtils.parseNumber("42", Integer.class);
    Double d = NumberUtils.parseNumber("3.14", Double.class);
    System.out.println(i); // 42
    System.out.println(d); // 3.14

    // String -> 原始类型
    int x = NumberUtils.parseNumber("123", int.class); // int 原始类型
    double y = NumberUtils.parseNumber("1.23", double.class);

    // 转换 Number -> 特定类型
    Number number = 42;
    int si = NumberUtils.convertNumberToTargetClass(number, Integer.class);
    double sd = NumberUtils.convertNumberToTargetClass(number, Double.class);

    System.out.println(si); // 42
    System.out.println(sd); // 42.0

    // 支持进制数字解析
    int hex = NumberUtils.parseNumber("0xA", Integer.class); // 10（十六进制）
    int oct = NumberUtils.parseNumber("075", Integer.class); // 61（八进制）
}
```

### 7.14) DigestUtils

 **Spring 提供的 `org.springframework.util.DigestUtils`**，是一个简化的哈希 / 摘要工具类，主要提供 MD5 算法的便捷方法。

```
// DigestUtils
public void digestUtils() {
    // 字符串 MD5（返回 32 位十六进制字符串）
    String md5 = DigestUtils.md5DigestAsHex("hello".getBytes());
    System.out.println(md5);

    // 签名
    // String sign = DigestUtils.md5DigestAsHex((timestamp + secret + payload).getBytes());

    // 字节
    byte[] bytes = DigestUtils.md5Digest("data".getBytes());

    // 文件md5，可以对文件校验
    try (InputStream is = new FileInputStream("test.txt")) {
        String md52 = DigestUtils.md5DigestAsHex(is);
        System.out.println(md52);
    } catch (FileNotFoundException e) {
        throw new RuntimeException(e);
    } catch (IOException e) {
        throw new RuntimeException(e);
    }
}
```

### 7.15) AnnotationUtils

 Spring 提供的 `org.springframework.core.annotation.AnnotationUtils`，是处理注解的工具类，简化了注解的查找、解析和默认值获取。

```
// AnnotationUtils
public static void annotationUtils() throws NoSuchMethodException {
    // 类上查找
    AnnotationUtils.findAnnotation(UserController.class, Controller.class);

    // 方法上查找
    Method method = UserController.class.getMethod("hello");
    RequestMapping mapping = AnnotationUtils.findAnnotation(method, RequestMapping.class);

    // 获取默认值
    String defaultValue = (String) AnnotationUtils.getDefaultValue(Controller.class, "path");
    System.out.println(defaultValue);
}
```



### 7.16) AntPathMatcher

```
//路径匹配, 这个非常使用, 比如我们自己构造了一个AB test系统, 或者是分流系统, 我们需要自己配置路由, 根据
//自己的路由规则进行跳转, 此时我们就可以用AntPathMatcher来解析请求路径, 然后转发到不同的服务即可
//再比如下Filter的时候, 需要排出你配置规则的URL, 不要登录或者验证, 此时也可以用到AntPathMatcher来解析请求路径
//而spring 内部其实也大量使用了这个类, 像咱们Controller内配置的各种Mapping 注解, 跨域配置, 拦截器配置、静态资源映射
public static void antPathMatcher(HttpServletRequest request) {
    AntPathMatcher matcher = new AntPathMatcher();
    if (matcher.match(pattern: "/public/**", request.getServletPath())) {
        // pass
    }
}
```

### 7.17) PatternMatchUtils

```
//简单的模式匹配, 判断字符串使用
public static void patternMatchUtils() {
    //判断以什么开头
    System.out.println(PatternMatchUtils.simpleMatch(pattern: "user*", str: "username")); // true
    System.out.println(PatternMatchUtils.simpleMatch(pattern: "user?", str: "username")); // false
    System.out.println(PatternMatchUtils.simpleMatch(pattern: "user?", str: "user1")); // false

    String[] grayIds = {"100*", "200*", "admin-*"}; // 一组匹配模式
    System.out.println(PatternMatchUtils.simpleMatch(grayIds, str: "10020")); // true
}
```

### 7.18) PropertyPlaceholderHelper

```
public static void propertyPlaceholderHelper() {
    // 替换${name}
    PropertyPlaceholderHelper helper =
        new PropertyPlaceholderHelper(placeholderPrefix: "${", placeholderSuffix: "}");

    String result = helper.replacePlaceholders(
        value: "Hello, ${name}!",
        key -> {
            if (key.equals("name")) return "Shark";
            return null;
        }
    );
    System.out.println(result); // Hello, Shark!

    // 支持默认值 server.port=${PORT:8080}
    // 嵌套占位符: ${outer${inner}}, 这个是 Spring Environment 和 PlaceholderConfigurer 的核心能力
    // 网关路由动态解析
    // route.url = https://${env}.api.xx.com
    // env = prod
    Map<String, String> props = Map.of(
        "env", "prod"
    );

    PropertyPlaceholderHelper helper2 =
        new PropertyPlaceholderHelper(placeholderPrefix: "${", placeholderSuffix: "}");
    String s = helper2.replacePlaceholders(
        value: "https://${env}.api.xx.com",
        props::get
    );
    System.out.println(s); // https://prod.api.xx.com

    // 动态消息文本模板解析(通知系统)
    String template = "您有一笔订单: ${orderId}, 金额 ${amount} 元";
    Map<String, String> map = Map.of(
        "orderId", "12345",
        "amount", "99.9"
    );
    String msg = helper.replacePlaceholders(template, map::get);
    System.out.println(msg);
}
```

### 7.19) linkedMultiValueMap

```
//多值映射的map, 其实本质 key list, Map<K, List<V>>
public static void linkedMultiValueMap() {
    LinkedMultiValueMap<String, String> filters = new LinkedMultiValueMap<>();
    filters.add("category", "phone");
    filters.add("category", "camera");
    filters.add("brand", "apple");
    filters.add("brand", "sony");

    System.out.println(filters.get("brand")); // [apple, sony]
}
```

### 7.20) StopWatch

Spring 提供的 `org.springframework.util.StopWatch`，是一个轻量级的性能计时工具，支持多任务分段计时，并能生成格式化的统计报告。

```
// 简单的计时工具, 性能计时工具类
public static void stopWatch() throws InterruptedException {
    StopWatch sw = new StopWatch("MultiTaskDemo");

    // 任务1 开始计时
    sw.start("Task1"); // 任务名称 Task1
    Thread.sleep(300); // 这里是你执行的业务逻辑
    sw.stop(); // 任务1 停止

    // 任务2
    sw.start("Task2");
    Thread.sleep(500);
    sw.stop();

    // 输出总耗时
    System.out.println("Total time: " + sw.getTotalTimeMillis() + " ms");

    // 输出任务详情
    System.out.println(sw.prettyPrint());
    /*
    StopWatch 'MultiTaskDemo': running time (millis) = 800
    -----------------------------------------
    ms     %     Task name
    -----------------------------------------
    00300  037%  Task1
    00500  063%  Task2
    */
}
```

### 7.21) ContentCachingRequestWrapper

基于 Spring 的请求日志过滤器，核心使用了 `ContentCachingRequestWrapper` 来解决**请求体只能读取一次**的问题。

```
public class LoggingFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        // 包装请求
        ContentCachingRequestWrapper wrappedRequest = new ContentCachingRequestWrapper(request);

        filterChain.doFilter(wrappedRequest, response);

        // 获取缓存的请求体
        byte[] content = wrappedRequest.getContentAsByteArray();
        String requestBody = new String(content, wrappedRequest.getCharacterEncoding());
        System.out.println("Request body: " + requestBody);
    }
}
```

## 8）Spring Boot 4 变化

