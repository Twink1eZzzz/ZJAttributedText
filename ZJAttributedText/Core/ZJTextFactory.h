//
//  ZJTextFactory.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/6.
//

#import <Foundation/Foundation.h>

@class ZJTextElement;

@interface ZJTextFactory : NSObject

/**
 绘制文本Layer

 @param elements 元素数组
 @param size 约束尺寸
 @return 绘制layer
 */
+ (CALayer *)textLayerWithElements:(NSArray<ZJTextElement *> *)elements constraint:(CGSize *)size;

@end
