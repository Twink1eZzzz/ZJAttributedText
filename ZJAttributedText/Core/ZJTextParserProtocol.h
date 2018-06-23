//
//  ZJTextParserProtocol.h
//  ZJAttributedText
//
//  Created by Zj on 2018/6/23.
//

#ifndef ZJTextParserProtocol_h
#define ZJTextParserProtocol_h

#import <Foundation/Foundation.h>

@class ZJTextElement, ZJTextAttributes;

/**
 解析完成Block

 @param elements 富文本元素
 @param defaultAttributes 默认属性
 */
typedef void(^ZJTextParseCompletionBlock)(NSArray<ZJTextElement *> *elements, ZJTextAttributes *defaultAttributes);

@protocol ZJTextParserProtocol

@required

/**
 将对象串解析为元素
 
 @param object 对象
 @param comletion 解析完成回调
 */
- (void)parseObject:(id)object comletion:(ZJTextParseCompletionBlock)comletion;

@end

#endif /* ZJTextParserProtocol_h */
