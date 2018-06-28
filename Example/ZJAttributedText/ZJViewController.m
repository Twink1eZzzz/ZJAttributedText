//
//  ZJViewController.m
//  ZJAttributedText
//
//  Created by Jsoul1227@hotmail.com on 06/04/2018.
//  Copyright (c) 2018 Jsoul1227@hotmail.com. All rights reserved.
//

#import "ZJViewController.h"
#import "ZJTextFactory.h"
#import "ZJTextElement.h"
#import "ZJTextAttributes.h"
#import "NSString+AttributedText.h"
#import "ZJTestLabel.h"
#import <objc/runtime.h>

@interface ZJViewController ()

@end

@implementation ZJViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //链式语法
    [self dotFeature];
    
    //最基础用法
    //[self baseFeature];
    
    //性能测试
    //[self performanceTest];
}

- (void)dotFeature {
    
    /************常量生成************/
    
    //回调
    ZJTextZJTextAttributeCommonBlock titleOnLayout = ^(ZJTextElement *element) {
        NSLog(@"已显示: %@", element.content);
    };
    ZJTextZJTextAttributeCommonBlock titleOnClicked = ^(ZJTextElement *element) {
        NSLog(@"标题被点击: %@", element.content);
    };
    ZJTextZJTextAttributeCommonBlock textOnClicked = ^(ZJTextElement *element) {
        NSLog(@"其他被点击: %@", element.content);
    };
    ZJTextZJTextAttributeCommonBlock bookOnClicked = ^(ZJTextElement *element) {
        NSLog(@"书被点击: %@", element.content);
    };
    
    //字体与颜色
    UIFont *titleFont = [UIFont boldSystemFontOfSize:20];
    UIColor *titleColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    UIColor *firstParaColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    UIFont *separateLineFont =[UIFont systemFontOfSize:15];
    UIColor *separateLineColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.7];
    UIFont *lastParaFont = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    UIFont *bookNameFont = [UIFont boldSystemFontOfSize:22];
    UIColor *bookNameColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    UIColor *quoteColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    
    //绘制大小限制
    NSValue *maxSize = [NSValue valueWithCGSize:CGSizeMake(325, 550)];
    NSValue *imageSize = [NSValue valueWithCGSize:CGSizeMake(35, 35)];
    
    //内容
    NSString *title = @"随笔\n\n";
    NSString *firstPara = @"       张嘉佳又出了新书，把书名取成《云边有个小卖部》。他说“时隔五年了，写给离开我们的人，写给陪伴我们的人，写给每个人心中的山和海。\n       《云边有个小卖部》离他上次的一本书，已经过去五年了。\n";
    NSURL *webImage = [NSURL URLWithString:@"http://osnabh9h1.bkt.clouddn.com/18-6-27/92507897.jpg"];
    NSString *separateLine = @"-----分界-----";
    NSString *localImagePath = [[NSBundle mainBundle] pathForResource:@"dy122" ofType:@"png"];
    UIImage *locolImage = [UIImage imageWithContentsOfFile:localImagePath];
    NSString *lastPara = @"\n我从来没想过时间会过的这么快，\n快的这五年我好像还没有认真生活，\n时间就没有了。\n没有认识新朋友，\n没有去过新景点，\n也没有吃过更新奇的食物，\n五年里没有任何值得留念的回忆。\n这本";
    NSString *bookName = @"《云边有个小卖部》";
    NSString *quote = @"\n\n       --他说，他陆陆续续写了两年，中间写到情绪崩溃，不得已停笔半年。";
    
    /************核心使用************/
    
    //1. 拼接文章
    
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
    
//        //2 .一次性生成文章
//
//        @""
//        .append(title).font(titleFont).color(titleColor).onClicked(titleOnClicked).onLayout(titleOnLayout)
//        .append(firstPara).color(firstParaColor).align(@0)
//        .append(webImage).font(separateLineFont).minLineHeight(@100)
//        .append(separateLine).font(separateLineFont).strokeColor(separateLineColor).strokeWidth(@1)
//        .append(locolImage)
//        .append(lastPara).font(lastParaFont).align(@1)
//        .append(bookName).font(bookNameFont).color(bookNameColor).onClicked(bookOnClicked).align(@1)
//        .append(quote).color(quoteColor).letterSpace(@0).minLineSpace(@8).align(@0)
//        //设置全局默认属性, 优先级低于指定属性
//        .entire().maxSize(maxSize).align(@2).letterSpace(@3).minLineHeight(@20).maxLineHeight(@20).imageAlign(@1).onClicked(textOnClicked).imageSize(imageSize)
//        //绘制View
//        .drawView(^(UIView *drawView) {
//            drawView.frame = CGRectMake(27.5, 50, drawView.frame.size.width, drawView.frame.size.height);
//            drawView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
//            [self.view addSubview:drawView];
//        });
}

- (void)baseFeature {
    
    //元素1
    ZJTextElement *element1 = [ZJTextElement new];
    element1.content = @"随笔\n\n";
    element1.attributes.font = [UIFont boldSystemFontOfSize:20];
    element1.attributes.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    element1.attributes.align = @2;
    element1.attributes.onLayout = ^(ZJTextElement *element) {
        NSLog(@"已显示: %@", element.content);
    };
    element1.attributes.onClicked = ^(ZJTextElement *element) {
        NSLog(@"标题被点击: %@", element.content);
    };
    
    //元素2
    ZJTextElement *element2 = [ZJTextElement new];
    element2.content = @"       张嘉佳又出了新书，把书名取成《云边有个小卖部》。他说“时隔五年了，写给离开我们的人，写给陪伴我们的人，写给每个人心中的山和海。\n       《云边有个小卖部》离他上次的一本书，已经过去五年了。\n";
    element2.attributes.color = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    element2.attributes.align = @0;
    
    //元素3
    ZJTextElement *element3 = [ZJTextElement new];
    NSString *image3Path = [[NSBundle mainBundle] pathForResource:@"dy008" ofType:@"png"];
    element3.content = [UIImage imageWithContentsOfFile:image3Path];
//    element3.attributes.imageSize =  [NSValue valueWithCGSize:CGSizeMake(30, 30)];
    element3.attributes.imageAlign = @(ZJTextImageAlignCenterToFont);
    element3.attributes.align = @2;
    element3.attributes.font = [UIFont systemFontOfSize:10];
    element3.attributes.minLineHeight = @100;
    
    //元素4
    ZJTextElement *element4 = [ZJTextElement new];
    element4.content = @"-----分界-----";
    element4.attributes.font = [UIFont systemFontOfSize:10];
    element4.attributes.color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    element4.attributes.strokeColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.7];
    element4.attributes.strokeWidth = @-2;
    element4.attributes.align = @2;
    element4.attributes.minLineHeight = @100;
    
    //元素5
    ZJTextElement *element5 = [ZJTextElement new];
    NSString *localImagePath = [[NSBundle mainBundle] pathForResource:@"dy122" ofType:@"png"];
    element5.content = [UIImage imageWithContentsOfFile:localImagePath];
    element5.attributes.imageAlign = @(ZJTextImageAlignCenterToFont);
    element5.attributes.align = @2;
    element5.attributes.font = [UIFont systemFontOfSize:10];
    element5.attributes.minLineHeight = @100;
    
    //元素6
    ZJTextElement *element6 = [ZJTextElement new];
    element6.content = @"\n我从来没想过时间会过的这么快，\n快的这五年我好像还没有认真生活，\n时间就没有了。\n没有认识新朋友，\n没有去过新景点，\n也没有吃过更新奇的食物，\n五年里没有任何值得留念的回忆。\n这本";
    element6.attributes.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    
    //元素7
    ZJTextElement *element7 = [ZJTextElement new];
    element7.content = @"《云边有个小卖部》";
    element7.attributes.font = [UIFont boldSystemFontOfSize:22];
    element7.attributes.color = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    element7.attributes.onClicked = ^(ZJTextElement *element) {
        NSLog(@"书名: %@", element.content);
    };
    
    //元素8
    ZJTextElement *element8 = [ZJTextElement new];
    element8.content = @"\n\n       --他说，他陆陆续续写了两年，中间写到情绪崩溃，不得已停笔半年。";
    element8.attributes.color = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    element8.attributes.letterSpace = @0;
    element8.attributes.align = @0;
    element8.attributes.minLineSpace = @8;
    
    //组成数组
    NSArray *elements = @[element1, element2, element3, element4, element5, element6, element7, element8];
    
    //默认属性
    ZJTextAttributes *defaultAttributes = [ZJTextAttributes new];
    defaultAttributes.maxSize = [NSValue valueWithCGSize:CGSizeMake(325, 550)];
    defaultAttributes.letterSpace = @3;
    defaultAttributes.minLineHeight = @20;
    defaultAttributes.maxLineHeight = @20;
    defaultAttributes.align = @1;
    defaultAttributes.imageAlign = @(ZJTextImageAlignCenterToFont);
    defaultAttributes.cacheFrame = @YES;
    defaultAttributes.onClicked = ^(ZJTextElement *element) {
        NSLog(@"其他文本: %@", element.content);
    };
    
    [ZJTextFactory drawTextViewWithElements:elements defaultAttributes:defaultAttributes completion:^(UIView *drawView) {
        drawView.frame = CGRectMake(27.5, 50, drawView.frame.size.width, drawView.frame.size.height);
        drawView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
        [self.view addSubview:drawView];
    }];
}

- (void)performanceTest {
    
    /*
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
     2. 越复杂的文本收益越高, (多控件合一, 异步绘制, 耗时增长少).
     */
    

//    //1. NSAttributedString + label
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"      陈一发儿了解一下? 冯提莫了解一下? 阿冷了解一下?"];
//    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, attributedString.length)];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[[UIColor blueColor] colorWithAlphaComponent:0.5] range:NSMakeRange(0, attributedString.length)];
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    style.lineSpacing = 10;
//    style.lineBreakMode = NSLineBreakByCharWrapping;
//    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedString.length)];
//
//    NSString *image1Path = [[NSBundle mainBundle] pathForResource:@"dy008" ofType:@"png"];
//    UIImage *image1 = [UIImage imageWithContentsOfFile:image1Path];
//    NSTextAttachment *attachment1 = [[NSTextAttachment alloc] init];
//    attachment1.image = image1;
//    NSAttributedString *attachString1 = [NSAttributedString attributedStringWithAttachment:attachment1];
//
//    NSString *image2Path = [[NSBundle mainBundle] pathForResource:@"dy122" ofType:@"png"];
//    UIImage *image2 = [UIImage imageWithContentsOfFile:image2Path];
//    NSTextAttachment *attachment2 = [[NSTextAttachment alloc] init];
//    attachment2.image = image2;
//    NSAttributedString *attachString2 = [NSAttributedString attributedStringWithAttachment:attachment2];
//
//    [attributedString appendAttributedString:attachString1];
//    [attributedString appendAttributedString:attachString2];
//
//    ZJTestLabel *label = [[ZJTestLabel alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 200)];
//    label.numberOfLines = 0;
//    label.attributedText = attributedString;
//
//    CGFloat startTime = [[NSDate date] timeIntervalSince1970] * 1000;
//    OnLayoutBlock onLayout = ^{
//        CGFloat endTime = [[NSDate date] timeIntervalSince1970] * 1000;
//        NSLog(@"绘制耗时: %f ms", endTime - startTime);
//        //iphone 6上 绘制耗时: 42.32 ms
//    };
//    label.onLayout = onLayout;
//    [self.view addSubview:label];
    
    
    //2. ZJAttributedText
    __block CGFloat startTime = 0;

    ZJTextZJTextAttributeCommonBlock onLayout = ^(ZJTextElement *element) {
        CGFloat endTime = [[NSDate date] timeIntervalSince1970] * 1000;
        NSLog(@"绘制耗时: %f ms", endTime - startTime);
        //iphone 6上 绘制耗时: 0.75 ms, (将onLayout放在视图的drawRect中执行的结果)
    };

    NSString *image1Path = [[NSBundle mainBundle] pathForResource:@"dy008" ofType:@"png"];
    UIImage *image1 = [UIImage imageWithContentsOfFile:image1Path];
    NSString *image2Path = [[NSBundle mainBundle] pathForResource:@"dy122" ofType:@"png"];
    UIImage *image2 = [UIImage imageWithContentsOfFile:image2Path];

    NSString *content =  @"      陈一发儿了解一下? 冯提莫了解一下? 阿冷了解一下?";

    content.font([UIFont systemFontOfSize:15]).color([[UIColor blueColor] colorWithAlphaComponent:0.5]).minLineSpace(@10).lineBreakMode(@1).onLayout(onLayout)
    .append(image1)
    .append(image2)
    .entire().maxSize([NSValue valueWithCGSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 200)])
    .drawView(^(UIView *drawView) {

        startTime = [[NSDate date] timeIntervalSince1970] * 1000;

        CGRect frame = drawView.frame;
        frame.origin.y = 50;
        drawView.frame = frame;
        [self.view addSubview:drawView];
    });
}

@end
