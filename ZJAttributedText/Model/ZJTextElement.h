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
 内容: 文本(NSString)或图片(UIImage)
 */
@property (nonatomic, strong) id content;

/**
 属性
 */
@property (nonatomic, strong) ZJTextAttributes *attributes;

/**
 在富文本中的范围
 */
@property (nonatomic, strong, readonly) NSValue *rangeValue;

/**
 在富文本中的绘制frame的数组
 */
@property (nonatomic, strong, readonly) NSArray<NSValue *> *frameValueArray;

/**
 在富文本中的绘制frame的数组, 此属性需要二次计算
 */
@property (nonatomic, strong, readonly) NSArray<NSValue *> *drawFrameValueArray;

@end
