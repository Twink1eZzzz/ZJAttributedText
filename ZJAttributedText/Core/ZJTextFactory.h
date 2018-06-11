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
 绘制文本视图

 @param elements 元素数组
 @param defaultAttributes 默认属性
 @return 绘制layer
 */
+ (UIView *)textViewWithElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes;

@end
