//
//  ZJTextFactory.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/6.
//

#import <Foundation/Foundation.h>

@class ZJTextElement, ZJTextAttributes;

@interface ZJTextFactory : NSObject

/**
 绘制文本View, 可响应手势
 
 @param elements 元素数组
 @param defaultAttributes 默认属性
 @param completion 绘制完成回调
 */
+ (void)drawTextViewWithElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes completion:(void(^)(UIView *drawView))completion;

/**
 绘制文本Layer, 不响应手势
 
 @param elements 元素数组
 @param defaultAttributes 默认属性
 @param completion 绘制完成回调
 */
+ (void)drawTextLayerWithElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes completion:(void(^)(CALayer *drawLayer))completion;

@end
