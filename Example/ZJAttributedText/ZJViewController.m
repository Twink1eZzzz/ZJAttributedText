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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
