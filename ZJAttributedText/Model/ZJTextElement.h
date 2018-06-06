//
//  ZJElement.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/4.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZJTextElementImageContentMode) {
    ZJTextElementImageContentModeAspectAspect = 0,
    ZJTextElementImageContentModeAspectScale
};

@class ZJTextAttribute;

@interface ZJTextElement : NSObject

#pragma mark - common

/**
 内容: 文本、图片、图片URL、继承自UIView的视图、继承自CALayer的视图
 */
@property (nonatomic, strong) id content;

/**
 属性
 */
@property (nonatomic, strong) ZJTextAttribute *attribute;

@end
