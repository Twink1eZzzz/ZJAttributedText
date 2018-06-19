//
//  ZJElement.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/4.
//

#import <Foundation/Foundation.h>

@class ZJTextAttributes;

@interface ZJTextElement : NSObject

#pragma mark - common

/**
 内容: 文本、图片、继承自UIView的视图、继承自CALayer的视图
 */
@property (nonatomic, strong) id content;

/**
 绘制出的图片
 */
@property (nonatomic, strong) UIImage *drawImage;

/**
 属性
 */
@property (nonatomic, strong) ZJTextAttributes *attributes;

/**
 在富文本中的范围
 */
@property (nonatomic, strong, readonly) NSValue *rangeValue;

/**
 在富文本中的frame
 */
@property (nonatomic, strong, readonly) NSValue *frameValue;

@end
