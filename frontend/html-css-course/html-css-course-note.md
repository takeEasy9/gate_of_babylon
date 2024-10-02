## 1.基本 HTML 标签
### 1.1. 文本标签
#### 1.1.1 标题
h1, h2, h3, h4, h5, h6
#### 1.1.2 段落
p
#### 1.1.3 列表
ul: 无需标签
ol: 有序标签
li: 列表项
#### 1.1.2. 图片
img:img 是一个特殊的 html 元素, 不包含任何内容。
img 元素 Attribute：
src:
alt: 替代文本，不仅是图像资源不存在时，在页面显示的内容，更是对图像描述，帮助浏览器理解图像内容， 也可以帮助盲人使用网站。
#### 1.1.3. 超链接
a: 超链接元素， href 属性使其真正成为一个链接，href 默认占位符 # ，点击回到页面顶部。
#### 1.1.4. 页面结构化标签
nav: 导航标签
header: header 标签
article: article 标签
footer:
aside: 放一些次要信息
#### 1.1.5. 语义化 HTML 标签
为什么语义化？
#### 1.1.6. VS Code 扩展
image preview
color highlight
auto rename tag
live server 

## 2.基础 CSS

### 2.1 CSS 三种方式

- 内联
- 内部
- 外部

### 2.2 CSS 与文本相关的6个属性

font-size:

font-family:

text-transform: 大小写转换、capitalize

font-style: 如 italic

text-align: 文本对齐

### 2.3 CSS 选择器

标签选择器

ID选择器

class选择器

id 只能使用一次，尽量使用class

### 2.4 CSS color

css 属性

color、background-color

rgb与rgba函数。

### 2.5 CSS pseudo class



first-child

last-child

nth-child

article p:first-child

a:link

a:visited

a:hover

a:active

a 标签伪类速记：LVHA

### 2.6 CSS Theory one

CSS 属性冲突时, 选择器优先级

Inline style (style attribute in HTML) > ID (#) selector > Class (.) or pseudo-class (:) selector > Element selector (p, div, li, etc) > Universal selector (*)

多个相同等级的选择器，最后一个生效。

!important

### 2.7 CSS 继承

文字相关属性大多可以被继承。

### 2.8 CSS Box Model

**content:** Text, images, etc

**border:** A line around element, still inside of the element

**padding:** Invisble space around the content, inside of the element

**margin:** Space outside of the element, between elements

**Fill area:** Area that gets filled with **background color** or **background image**

**Final element width** =  left boder + left padding + width + right padding + right border

**Final element height** =  top boder + top padding + height+ bottom padding + bottom border

**collapse margins**:

width: 百分比

页面居中：

 margin-left: auto;

 margin-right: auto;

子元素宽度不会大于父元素。

### 2.9 CSS Box Type

inline box:

- Occupies only the sapce necessary for its content
- Causes no line-breaks after or before the element
- Box model applies in a different way: heights and widths do not apply
- Paddings and margins are applied only horizontally(left and right)

block-level box / block-level element:

- Elements are formatted visually as blocks

- Elements occupy 100% of parent element's width

- Elements are stacked vertically by default , one after another

- The box-model applies as showed earlier

  DeFault elements: body, main, header, footer, section, nav, aside, div, h1-h6, p, ul, ol, li

  with CSS: display: block

inline box:

### 2.10 Absolute positioning

2.11 伪类

**::first-letter**

**::first-line**

相邻兄弟选择器: **h3 + p::first-line**

**::after**

**::before**

所有伪元素都是 inline element

## 3. CSS Layouts

### 3.1 Float

高度坍塌：

Float VS Absolute

clear float

**box-sizing: **改变CSS默认盒子模型

### 3.2 FLex

display: flex

align-items: 默认值 stretch, 垂直居中， 所有元素与最高元素一样高。

justify-content: 水平居中

**FLEX CONTAINER**

**gap: 0** | <length>

To create space between items, without using margin

**justify-content: flex-start**  | flex-end | center | space-between | sapce-around | space-evenly

To align items along main axis (**horizontally** , by default)

**align-items: stretch** | flext-strat | flex-end | cetnter | baseline

To align items along cross axis(vertically, by default)

**flex-direction: row** | row-reverse | column | column-reverse

To define which is the main axis

**flex-wrap: nowrap** | wrap | wrap-reverse

To allow items to wrap into a new line if they are too large

**align-content: stretch** | flex-start | flex-end | center | space-between | space-around 

only applies when there are **multiple lines** (flex-wrap: wrap)

**FLEX ITEMS**

**align-self: auto** | stretch | flex-start | flex-end | center | baseline

To overwrite align-items for individual flex items

**flex-grow: 0 **| <integer>

To allow an element **to grow** (0 means no, 1+ means yes)

**flext-shrink: 1** | <integer>

To allow an element **to shrink**  (0 means no, 1+ means yes)

**flex-basis: auto** | <length>

To define an item's width, **instead of the width** property

**flex: 0 1 auto **| <int> <int> <len>

Recommended shorthand for flex-grow, -shrink, -basis

**order: 0** | <integer>

Controls order of items. -1 makes item first, 1 makes it last



Flex property

默认值

​    flex-grow: 0; 设置设置flex items 宽度分配比例

​    flex-shrink: 1; 允许在必要时收缩元素。

​    flex-basis: auto; 设置flex items 宽度

 flex: 0 0 200px; flex-grow、flex-shrink、 flex-basis速记形式

### 3.3 CSS Grid

gap： 使用gap而不是margin创建边距

column-gap:

row-gap:

1fr 

指定网格位置：

  grid-column: 1 / 2;  

  grid-row: 2 / 3;

只跨一个网格时可以省略为：

rid-column: 1 ;  

  grid-row: 2 ;



跨多个个网格时可以省略为：

**rid-column: 1 / 3**;  

  grid-row: 2 ;



通过span指定跨越网格数量：

**rid-column: 1 /  span 2**;  

  grid-row: 2 ;

跨越到最后

**rid-column: 1 /  -1**;  

  grid-row: 2 ;

网格水平居中：justify-content: center;

网格垂直居中: align-content: center;

网格内容水平居中：align-items: center;

网格内容垂直居中：justify-items: center;

## 4. Web Design

4.1 网页设计-字体

字体大小， 字体粗细:

普通文本 推荐 font size 在16px-32px之间。

长文本 推荐 20px或更大的值。

标题 推荐 50px, font weight 600 +

对于任何文本， 不要使用400以下的字体粗细

每行文本应该少于75字符

普通大小文本 行高在 1.5 到 2， 大文本应小于 1.5

减少标题中的字符间距

小标题全部大写

对于文本，不要使用两端对齐。

长文本不要水平居中

4.2 



# HTML

HTML 文档结构 head、body， body 是页面可见内容。

head 下的标签：

title: 页面标题

meta

title

body 下的标签：



文本标签

h1~h6 标签， 标题，每个页面应该仅有一个 h1 标题， h2 标题不一定需要比 h1标题字号小。

p 标签，段落。

strong 标签，文本显示粗体，使用 strong 标签， 而不是 b 标签 ，b 标签没有任何语义 。

em 标签，文本显示斜体，使用 em 标签， 而不是 i 标签 ，i 标签没有任何语义 。

ol 有序列表

ul 无序列表

li  list item 列表项

图像

img 标签， 属性 src ，指定图片路径， alt 描述图片，在图片加载失败时显示，为使用屏幕阅读器的盲人服务。

width 图片宽度， height 图片高度。

链接

a 标签， 属性 href ，只有设置  href 属性 时  a 标签 才会被认为是链接，如果暂时不确定链接指向何处，可以暂时设置为 #， 创建一个空链接。

页面结构化标签

容器标签

导航 nav 标签

header 标签

article 标签

aside 标签

footer 标签

**语义化 html**

html 代表的 语义

语义化优点：

搜索引擎优化

可访问性









# CSS

内联、内部、外部 CSS。

文本

`color`

`font-size`

`font-family`

`text-transform`

`font-style`

`font-weight`

`line-height`

`text-align`

颜色

color

background-color

boder

RGB Model

rgba 函数

background-color

选择器

ID (#)选择器

Class (.)选择器

Element 选择器

ID 唯一，因此 ID 选择器 复用性低，元素选择器在HTML结构变化时难以维护，大多数情况下使用Class 选择器。

伪类(:): 伪类是选择器的一种，它用于选择处于特定状态的元素。

`:first-child`

`:last-child`

`nth-child(num)`

`nth-child(odd)`

`nth-child(even)`

`:link`

`:visited`

`:hover`

`:active`

通用选择器(*)

选择器优先级

!import > inline style > ID 选择器  > Class 选择器 或伪类选择器 > Element 选择器 > 通用选择器

CSS 继承

并不是所有属性都会被继承，大多数与文本相关的属性会被继承。

CSS 盒模型

盒模型默认行为

collapsing margin : 外边距合并

CSS Box Type

display:

inline、block、inline-block

CSS 定位

绝对定位 position: absolute

伪元素

::first-letter

::first-line

相邻兄弟选择器 h3 + p

::before

::after

CSS Layout

Flaot Layout

.clearfix::after {

​	clear:both;

​	content: "";

​	display: block

}



# VS code 设置

prettier 插件

One MonoKai: 主题

default formatter 设置为 prettier

format on save 设置为 勾选

auto save 设置为 onFocusChange

tab size 设置为 2

file icon theme 设置为 Seti

auto closing tags

image preview 插件

color highligter 插件

auto rename tag 插件

live server 插件

技巧：

- ! 快速生成 html 模板代码。



# 相关网站

MDN: [MDN Web Docs (mozilla.org)](https://developer.mozilla.org/zh-CN/)

[CodePen: Online Code Editor and Front End Web Developer Community](https://codepen.io/)

[Glyphs | CSS-Tricks](https://css-tricks.com/snippets/html/glyphs/)

HTML Validator

[Diffchecker - 在线比较文本，并找出两个文本文件之间的差异](https://www.diffchecker.com/zh-Hans/)









