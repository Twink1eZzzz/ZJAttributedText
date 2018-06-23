//
//  ZJViewController.m
//  ZJAttributedText
//
//  Created by 281925019@qq.com on 06/04/2018.
//  Copyright (c) 2018 281925019@qq.com. All rights reserved.
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

    
    NSString *imagePath = [[NSBundle bundleForClass:[ZJTextElement class]] pathForResource:@"test" ofType:@"png"];
//    UIImage *image2 = [UIImage imageWithContentsOfFile:imagePath];
    
    ZJTextElement *element1 = [ZJTextElement new];
    element1.content = @"你看看大伙儿合照, 就你一个人没有笑, 是我们装傻, 还是你真的, 有很多普通人没有的困扰, 我才懒得给你解药, 反正你爱来这一套, 为爱情折腰, ";
    element1.attributes.color = [[UIColor redColor] colorWithAlphaComponent:0.8];

    
    ZJTextElement *element2 = [ZJTextElement new];
    element2.content = @"难道不是你, 一直以来戒不掉的癖好, 你在想谁想到睡不着, 你应该觉得骄傲, 很多人想失恋也没有目标";
    element2.attributes.color = [[UIColor greenColor] colorWithAlphaComponent:0.8];
    element2.attributes.imageSizeValue = [NSValue valueWithCGSize:CGSizeMake(25, 25)];
//    attributes2.verticalCenter = @YES;
//    attributes2.verticalOffset = @-10;
//    attributes2.verticalOffset = @15;
    element2.attributes.onClicked = ^{
        NSLog(@"element2 :%s", __func__);
    };
    element2.attributes.imageAlign = ZJTextImageAlignCenterToFont;
    
    
    ZJTextElement *element3 = [ZJTextElement new];
    UIImage *image3 = [UIImage imageWithContentsOfFile:imagePath];
    element3.content = image3;
    ZJTextAttributes *attributes3 = [ZJTextAttributes new];
//    attributes3.imageSizeValue =  [NSValue valueWithCGSize:CGSizeMake(30, 30)];
//    attributes3.verticalOffset = @-10;
    element3.attributes = attributes3;
    element3.attributes.imageAlign = ZJTextImageAlignCenterToFont;
    
    
    ZJTextElement *element4 = [ZJTextElement new];
    element4.content = @"element4";
    ZJTextAttributes *attributes4 = [ZJTextAttributes new];
    attributes4.font = [UIFont systemFontOfSize:20];
    attributes4.color = [UIColor redColor];
    attributes4.strokeColor = [UIColor blueColor];
    attributes4.strokeWidth = @-1;
    attributes4.letterSpace = @10;
//    attributes4.lineSpace = @1;
//    attributes4.verticalCenter = @YES;
    element4.attributes = attributes4;
    
    ZJTextElement *element5 = [ZJTextElement new];
    element5.content = @"萨德阿萨德德阿萨阿萨阿萨德德阿萨阿萨阿萨德德阿萨阿萨阿萨德德阿萨阿萨德";
    ZJTextAttributes *attributes5 = [ZJTextAttributes new];
//    attributes5.verticalOffset = @-3;
    element5.attributes = attributes5;
//    element5.attributes.underline = @11;
//    attributes5.verticalOffset = @-10;
//    element5.attributes.verticalForm = @-1;
    element5.attributes.onClicked = ^{
        NSLog(@"element5 :%s", __func__);
    };

    NSArray *elements = @[element1, element2, element3, element4, element5];

    ZJTextAttributes *defaultAttributes = [ZJTextAttributes new];
    defaultAttributes.constraintSizeValue = [NSValue valueWithCGSize:CGSizeMake(300, 500)];
    defaultAttributes.letterSpace = @2;

    defaultAttributes.minLineSpace = @10;
    defaultAttributes.minLineHeight = @30;
    defaultAttributes.imageAlign = ZJTextImageAlignCenterToFont;
    defaultAttributes.cacheFrame = @YES;    defaultAttributes.onClicked = ^{
      NSLog(@"%s", __func__);
    };
    
    [ZJTextFactory drawTextViewWithElements:elements defaultAttributes:defaultAttributes completion:^(UIView *draw) {
//        draw.frame = CGRectMake(50, 50, draw.frame.size.width, draw.frame.size.height);
//
//        NSArray *frameValueArray = element3.frameValueArray;
//        for (NSValue *frameValue in frameValueArray) {
//            CALayer *layer = [CALayer layer];
//            layer.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2].CGColor;
//            CGRect frame = [frameValue CGRectValue];
//            layer.frame = frame;
//            [draw.layer addSublayer:layer];
//        }
//
//
//        [self.view.layer addSublayer:draw];
        
        draw.frame = CGRectMake(50, 50, draw.frame.size.width, draw.frame.size.height);
        [self.view addSubview:draw];
    }];
//    for (NSInteger i = 0; i < 1500000; i++) {
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [view setNeedsDisplay];
////        });
//    }
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [view removeFromSuperview];
//        UIView *newView = [ZJTextFactory textViewWithElements:nil defaultAttribute:nil];
//        newView.frame = CGRectMake(100, 100, 100, 100);
//        [self.view addSubview:newView];
//    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
