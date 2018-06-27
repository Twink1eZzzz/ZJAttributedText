//
//  ZJTestLabel.m
//  ZJAttributedText_Example
//
//  Created by zhangjun on 2018/6/27.
//  Copyright © 2018年 281925019@qq.com. All rights reserved.
//

#import "ZJTestLabel.h"

@implementation ZJTestLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    if (_onLayout) {
        _onLayout();
    }
}

@end
