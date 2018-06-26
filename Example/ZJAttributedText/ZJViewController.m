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
#import <objc/runtime.h>

@interface ZJViewController ()

@end

@implementation ZJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //最基础用法
    [self baseFeature];
    
    
}

- (void)baseFeature {
    
    NSString *imagePath = [[NSBundle bundleForClass:[ZJTextElement class]] pathForResource:@"test" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
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
    element2.attributes.imageSizeValue = [NSValue valueWithCGSize:CGSizeMake(40, 40)];
    element2.attributes.align = @0;
    
    //元素3
    ZJTextElement *element3 = [ZJTextElement new];
    element3.content = image;
    element3.attributes.imageSizeValue =  [NSValue valueWithCGSize:CGSizeMake(30, 30)];
    element3.attributes.imageAlign = @(ZJTextImageAlignCenterToFont);
    element3.attributes.align = @2;
    
    //元素4
    ZJTextElement *element4 = [ZJTextElement new];
    element4.content = @"分界线";
    element4.attributes.font = [UIFont systemFontOfSize:15];
    element4.attributes.color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    element4.attributes.strokeColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.7];
    element4.attributes.strokeWidth = @-2;
    element4.attributes.align = @2;
    
    //元素5
    ZJTextElement *element5 = [ZJTextElement new];
    element5.content = image;
    element5.attributes.imageAlign = @(ZJTextImageAlignCenterToFont);
    element5.attributes.align = @2;
    
    //元素6
    ZJTextElement *element6 = [ZJTextElement new];
    element6.content = @"\n我从来没想过时间会过的这么快，\n快的这五年我好像还没有认真生活，\n时间就没有了。\n没有认识新朋友，\n没有去过新景点，\n也没有吃过更新奇的食物，\n五年里没有任何值得留念的回忆。\n这本";
    element6.attributes.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    
    //元素7
    ZJTextElement *element7 = [ZJTextElement new];
    element7.content = @"《云边有个小卖部》";
    element7.attributes.font = [UIFont boldSystemFontOfSize:16];
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
    defaultAttributes.constraintSizeValue = [NSValue valueWithCGSize:CGSizeMake(325, 500)];
    defaultAttributes.letterSpace = @3;
    defaultAttributes.minLineHeight = @20;
    defaultAttributes.align = @1;
    defaultAttributes.imageAlign = @(ZJTextImageAlignCenterToFont);
    defaultAttributes.cacheFrame = @YES;
    defaultAttributes.onClicked = ^(ZJTextElement *element) {
        NSLog(@"其他文本: %@", element.content);
    };
    
    [ZJTextFactory drawTextViewWithElements:elements defaultAttributes:defaultAttributes completion:^(UIView *draw) {
        draw.frame = CGRectMake(27.5, 50, draw.frame.size.width, draw.frame.size.height);
        draw.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
        [self.view addSubview:draw];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
