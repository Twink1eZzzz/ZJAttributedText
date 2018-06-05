//
//  ZJParagraph.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/4.
//

#import <Foundation/Foundation.h>
#import "ZJElement.h"

@interface ZJParagraph : NSObject

#pragma mark - common

/**
 段落中元素
 */
@property (nonatomic, strong) NSArray<ZJElement *> *elements;

/**
 垂直偏移
 */
@property (nonatomic, assign) CGFloat verticalOffset;

/**
 约束大小
 */
@property (nonatomic, assign) CGSize constraintSize;

/**
 字间距
 */
@property (nonatomic, assign) CGFloat space;

/**
 行间距
 */
@property (nonatomic, assign) CGFloat lineSpace;

#pragma mark - text

/**
 字体
 */
@property (nonatomic, strong) UIFont *font;

/**
 颜色
 */
@property (nonatomic, strong) UIColor *color;

@end
