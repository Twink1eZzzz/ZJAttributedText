//
//  ZJTextFactory.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/6.
//

#import <Foundation/Foundation.h>

typedef void(^ZJAttributesTextDrawCompletionBlock)(id draw);

@class ZJTextElement, ZJTextAttributes;

@interface ZJTextFactory : NSObject

/**
 绘制文本Layer
 
 @param elements 元素数组
 @param defaultAttributes 默认属性
 @param completion 绘制完成回调
 */
+ (void)drawTextLayerWithElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes completion:(ZJAttributesTextDrawCompletionBlock)completion;

@end
