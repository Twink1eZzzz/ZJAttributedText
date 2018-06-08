//
//  ZJViewController.m
//  ZJAttributedText
//
//  Created by 281925019@qq.com on 06/04/2018.
//  Copyright (c) 2018 281925019@qq.com. All rights reserved.
//

#import "ZJViewController.h"
#import "ZJTextFactory.h"

@interface ZJViewController ()

@end

@implementation ZJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    

    UIView *view = [ZJTextFactory textViewWithElements:nil constraint:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    view.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:view];
    for (NSInteger i = 0; i < 150000; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view setNeedsDisplay];
        });
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
