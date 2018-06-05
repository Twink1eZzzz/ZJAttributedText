//
//  ZJElement.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/4.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZJElementImageContentMode) {
    ZJElementImageContentModeAspect = 0,
    ZJElementImageContentModeScale
};

@interface ZJElement : NSObject

#pragma mark - common

/**
 内容: 文本、图片、图片URL、继承自UIView的视图、继承自CALayer的视图
 */
@property (nonatomic, strong) id content;

/**
 垂直偏移
 */
@property (nonatomic, assign) CGFloat verticalOffset;

/**
 字间距
 */
@property (nonatomic, assign) CGFloat space;

/**
 行间距
 */
@property (nonatomic, assign) CGFloat lineSpace;

#pragma mark - image

/**
 图片期望大小
 */
@property (nonatomic, assign) CGSize predictImageSize;

/**
 图片展示模式
 */
@property (nonatomic, assign) ZJElementImageContentMode imageContentMode;

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
