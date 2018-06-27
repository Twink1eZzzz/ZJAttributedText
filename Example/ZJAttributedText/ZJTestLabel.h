//
//  ZJTestLabel.h
//  ZJAttributedText_Example
//
//  Created by zhangjun on 2018/6/27.
//  Copyright © 2018年 281925019@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OnLayoutBlock)(void);

@interface ZJTestLabel : UILabel

@property (nonatomic, copy) OnLayoutBlock onLayout;

@end
