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
 属性
 */
@property (nonatomic, strong) ZJTextAttributes *attributes;

/**
 生成富文本

 @param defaultAttributes 默认属性
 @param ignored 是否忽略缓存
 @return 富文本
 */
- (NSAttributedString *)generateAttributedStringWithDefaultAttributes:(ZJTextAttributes *)defaultAttributes ignoredCache:(BOOL)ignored;

/**
 重新生成富文本

 @return 富文本
 */
- (NSAttributedString *)regenerateAttributedString;

@end
