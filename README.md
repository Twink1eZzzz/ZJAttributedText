# ZJAttributedText

## 高性能轻量级富文本框架

[![CI Status](https://img.shields.io/travis/Jsoul1227@hotmail.com/ZJAttributedText.svg?style=flat)](https://travis-ci.org/Jsoul1227@hotmail.com/ZJAttributedText)
[![Version](https://img.shields.io/cocoapods/v/ZJAttributedText.svg?style=flat)](https://cocoapods.org/pods/ZJAttributedText)
[![License](https://img.shields.io/cocoapods/l/ZJAttributedText.svg?style=flat)](https://cocoapods.org/pods/ZJAttributedText)
[![Platform](https://img.shields.io/cocoapods/p/ZJAttributedText.svg?style=flat)](https://cocoapods.org/pods/ZJAttributedText)

## 示例说明
![](http://osnabh9h1.bkt.clouddn.com/18-6-28/77389949.jpg)

如图所示一篇图文混排, 涉及到字体, 颜色, 字间距, 行间距, 图片对齐, 文字对齐, 描边等等属性, 还有网络图片与本地图片混排, 手势响应等需求, 使用本框架可以下面这样实现:

```C
//...省略常量声明

//标题
title.font(titleFont).color(titleColor).onClicked(titleOnClicked).onLayout(titleOnLayout);
//首段
firstPara.color(firstParaColor).align(@0);
//图片需要用一个空字符串起头
NSString *webImageString = @"".append(webImage).font(separateLineFont).minLineHeight(@100);
//分割线
separateLine.font(separateLineFont).strokeColor(separateLineColor).strokeWidth(@1);
//本地图片
NSString *locolImageString = @"".append(locolImage);
//最后一段
lastPara.font(lastParaFont).align(@1);
//书名
bookName.font(bookNameFont).color(bookNameColor).onClicked(bookOnClicked).align(@1);
//引用
quote.color(quoteColor).letterSpace(@0).minLineSpace(@8).align(@0);

//设置全局默认属性, 优先级低于指定属性
NSString *defaultAttributes = @"".entire()
.maxSize(maxSize).align(@2).letterSpace(@3).minLineHeight(@20).maxLineHeight(@20).imageAlign(@1).onClicked(textOnClicked).imageSize(imageSize);

//拼接
title.append(firstPara).append(webImageString).append(separateLine).append(locolImageString).append(lastPara).append(bookName).append(quote)
//设置默认属性
.append(defaultAttributes)
//绘制View
.drawView(^(UIView *drawView) {
drawView.frame = CGRectMake(27.5, 50, drawView.frame.size.width, drawView.frame.size.height);
drawView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
[self.view addSubview:drawView];
});
```

甚至可以这样实现:

```C
//...省略常量声明

@""
//拼接全文
.append(title).font(titleFont).color(titleColor).onClicked(titleOnClicked).onLayout(titleOnLayout)
.append(firstPara).color(firstParaColor).align(@0)
.append(webImage).font(separateLineFont).minLineHeight(@100)
.append(separateLine).font(separateLineFont).strokeColor(separateLineColor).strokeWidth(@1)
.append(locolImage)
.append(lastPara).font(lastParaFont).align(@1)
.append(bookName).font(bookNameFont).color(bookNameColor).onClicked(bookOnClicked).align(@1)
.append(quote).color(quoteColor).letterSpace(@0).minLineSpace(@8).align(@0)
//设置默认属性
.entire().maxSize(maxSize).align(@2).letterSpace(@3).minLineHeight(@20).maxLineHeight(@20).imageAlign(@1).onClicked(textOnClicked).imageSize(imageSize)
//绘制
.drawView(^(UIView *drawView) {
drawView.frame = CGRectMake(27.5, 50, drawView.frame.size.width, drawView.frame.size.height);
drawView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
[self.view addSubview:drawView];
});

```

## 核心方法与属性

##### 核心方法

```C
/**
拼接字符串
可以是文本(NSString)、图片(UIImage)、图片链接(NSURL)(必须指定imageSize属性)
*/
@property (nonatomic, copy) ZJTextDotAppendBlock append;

/**
设置整段富文本
优先级低于指定属性, 较为重要的属性 maxSize 设置绘制约束
*/
@property (nonatomic, copy) ZJTextDotEntireBlock entire;

/**
绘制layer, 无法响应手势
*/
@property (nonatomic, copy) ZJTextDotLayerDrawBlock drawLayer;

/**
绘制View, 可响应手势
*/
@property (nonatomic, copy) ZJTextDotViewDrawBlock drawView;
```

##### 属性

```C
#pragma mark - common attributes

/**
竖直方向偏移
*/
@property (nonatomic, strong) NSNumber *verticalOffset;

/**
点击响应Block
*/
@property (nonatomic, copy) ZJTextZJTextAttributeCommonBlock onClicked;

/**
显示后会调用, 整段富文本设置其中一个元素即可
*/
@property (nonatomic, copy) ZJTextZJTextAttributeCommonBlock onLayout;

/**
是否缓存frame, 会计算文本在整段富文本中的frame
*/
@property (nonatomic, strong) NSNumber *cacheFrame;

#pragma mark - string attributes

/**
字体: 文字字体/图片居中对齐字体
*/
@property (nonatomic, strong) UIFont *font;

/**
颜色
*/
@property (nonatomic, strong) UIColor *color;

/**
字间距
*/
@property (nonatomic, strong) NSNumber *letterSpace;

/**
描边宽度, 整数为镂空, Color不生效; 负数Color生效
*/
@property (nonatomic, strong) NSNumber *strokeWidth;

/**
描边颜色
*/
@property (nonatomic, strong) UIColor *strokeColor;

/**
文字绘制随文字书写方向, 默认 否(0), 是(非0)
*/
@property (nonatomic, strong) NSNumber *verticalForm;

/**
下划线类型, 整形, 0为none, 1为细线 2为加粗 9为双条 参考 CTUnderlineStyle(仅枚举了三种, 其他值也有不同效果)
*/
@property (nonatomic, strong) NSNumber *underline;

#pragma mark - image attributes

/**
图片尺寸, 默认为图片本身尺寸
*/
@property (nonatomic, strong) NSValue *imageSize;

/**
图片对齐模式, 0为默认, 基准线对齐. 1为居中对齐至特定字体大小 参看 ZJTextImageAlign
*/
@property (nonatomic, strong) NSNumber *imageAlign;

#pragma mark - paragraph attributes

/**
绘制的约束尺寸, 默认Max
*/
@property (nonatomic, strong) NSValue *maxSize;

/**
最小行间距
*/
@property (nonatomic, strong) NSNumber *minLineSpace;

/**
最大行间距
*/
@property (nonatomic, strong) NSNumber *maxLineSpace;

/**
最小行高
*/
@property (nonatomic, strong) NSNumber *minLineHeight;

/**
最小行高
*/
@property (nonatomic, strong) NSNumber *maxLineHeight;

/**
对齐, 整形, 0为默认靠左 1为靠右 2为居中, 参考 CTTextAlignment
*/
@property (nonatomic, strong) NSNumber *align;

/**
对齐, 整形, 参考 NSLineBreakMode
*/
@property (nonatomic, strong) NSNumber *lineBreakMode;
```

## 性能

总体采用 CoreText + 异步绘制图片完成, 理论上性能会比较高, 经过测试如下数据供参考:

内容: 一段文本加上两张图片

机型: iPhone 6

测试结果:

常规过程: 创建->显示(绘制)
常规分析:
1. 主线程代码在 28ms 左右. (主线程代码开始 至 结束耗时)
2. UILabel 显示(绘制)耗时在 42ms 左右. (addSubview 至 drawRect 耗时)
3. 综合耗时 70ms 左右, 全部在主线程

异步绘制过程: 创建->异步绘制->显示
异步绘制分析:
1. 主线程(创建)代码在 28ms 左右. (主线程代码开始 至 结束耗时)
2. 创建(主线程) + 异步绘制耗时 84ms 左右. (主线程代码开始 至 绘制出图片回调)
3. 由 1、2 得出子线程绘制耗时 56ms 左右, 另外经过多次试验(大段文字绘制)得出绘制复杂的段落也耗时增长较少
4. 显示耗时 0.75 ms 左右. (addSubview 至 drawRect 耗时)
5. 综合耗时 85ms 左右, 其中主线程 29ms, 子线程 56ms

结论:
1. 相较于常规方式降低了主线程压力 70ms -> 29ms
2. 越复杂的文本收益越高, (多控件合一, 异步绘制, 耗时增长少)

## 依赖

网络图片异步绘制部分依赖 SDWebImage.

## 安装

[CocoaPods](https://cocoapods.org):

```ruby
pod 'ZJAttributedText'
```

## 作者

Jsoul1227@hotmail.com

## 许可证

ZJAttributedText is available under the MIT license. See the LICENSE file for more info.
