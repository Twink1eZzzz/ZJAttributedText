//
//  NSString+AttributedText.h
//  ZJAttributedText
//
//  Created by Zj on 2018/6/23.
//

#import <Foundation/Foundation.h>

typedef NSString *(^ZJTextDotFontBlock)(UIFont *font);

@interface NSString (AttributedText)

/**
 设置字体
 */
@property (nonatomic, copy) ZJTextDotFontBlock font;

@end
