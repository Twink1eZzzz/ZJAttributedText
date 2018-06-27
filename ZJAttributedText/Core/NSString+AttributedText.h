//
//  NSString+AttributedText.h
//  ZJAttributedText
//
//  Created by Zj on 2018/6/23.
//

#import <Foundation/Foundation.h>
#import "ZJTextAttributes.h"

typedef NSString *(^ZJTextDotFontBlock)(UIFont *font);
typedef NSString *(^ZJTextDotColorBlock)(UIColor *color);
typedef NSString *(^ZJTextDotValueBlock)(NSValue *value);
typedef NSString *(^ZJTextDotNumberBlock)(NSNumber *number);
typedef NSString *(^ZJTextDotBlockBlock)(ZJTextZJTextAttributeCommonBlock block);
typedef NSString *(^ZJTextDotAppendBlock)(id content);
typedef NSString *(^ZJTextDotEntireBlock)(void);
typedef void(^ZJTextLayerDrawCompletionBlock)(CALayer *drawLayer);
typedef NSString *(^ZJTextDotLayerDrawBlock)(ZJTextLayerDrawCompletionBlock completion);
typedef void(^ZJTextViewDrawCompletionBlock)(UIView *drawView);
typedef NSString *(^ZJTextDotViewDrawBlock)(ZJTextViewDrawCompletionBlock completion);

@interface NSString (AttributedText)

#pragma mark - core method

/**
 拼接字符串
 */
@property (nonatomic, copy) ZJTextDotAppendBlock append;

/**
 设置整段富文本
 */
@property (nonatomic, copy) ZJTextDotEntireBlock entire;

/**
 绘制layer, 无法响应手势
 */
@property (nonatomic, copy) ZJTextDotLayerDrawBlock drawLayer;

/**
 绘制View, 可响应手势
 */
@property (nonatomic, copy) ZJTextDotViewDrawBlock drawView;

#pragma mark - common attributes

/**
 竖直方向偏移
 */
@property (nonatomic, copy) ZJTextDotNumberBlock verticalOffset;

/**
 点击Block
 */
@property (nonatomic, copy) ZJTextDotBlockBlock onClicked;

/**
 显示后会调用, 整段富文本设置其中一个元素即可
 */
@property (nonatomic, copy) ZJTextDotBlockBlock onLayout;

/**
 是否缓存frame, 会计算文本在整段富文本中的frame
 */
@property (nonatomic, copy) ZJTextDotNumberBlock cacheFrame;

#pragma mark - string attributes

/**
 字体: 文字字体/图片居中对齐字体
 */
@property (nonatomic, copy) ZJTextDotFontBlock font;

/**
 颜色
 */
@property (nonatomic, copy) ZJTextDotColorBlock color;

/**
 字间距
 */
@property (nonatomic, copy) ZJTextDotNumberBlock letterSpace;

/**
 描边宽度, 整数为镂空, Color不生效; 负数Color生效
 */
@property (nonatomic, copy) ZJTextDotNumberBlock strokeWidth;

/**
 描边颜色
 */
@property (nonatomic, copy) ZJTextDotColorBlock strokeColor;

/**
 文字绘制随文字书写方向, 默认 否(0), 是(非0)
 */
@property (nonatomic, copy) ZJTextDotNumberBlock verticalForm;

/**
 下划线类型, 整形, 0为none, 1为细线 2为加粗 9为双条 参考 CTUnderlineStyle(仅枚举了三种, 其他值也有不同效果)
 */
@property (nonatomic, copy) ZJTextDotNumberBlock underline;

#pragma mark - image attributes

/**
 图片尺寸, 默认为图片本身尺寸
 */
@property (nonatomic, copy) ZJTextDotValueBlock imageSizeValue;

/**
 图片对齐模式 参看 ZJTextImageAlign
 */
@property (nonatomic, copy) ZJTextDotNumberBlock imageAlign;

#pragma mark - paragraph attributes

/**
 绘制的约束尺寸, 默认Max
 */
@property (nonatomic, copy) ZJTextDotValueBlock constraintSizeValue;

/**
 最小行间距
 */
@property (nonatomic, copy) ZJTextDotNumberBlock minLineSpace;

/**
 最大行间距
 */
@property (nonatomic, copy) ZJTextDotNumberBlock maxLineSpace;

/**
 最小行高
 */
@property (nonatomic, copy) ZJTextDotNumberBlock minLineHeight;

/**
 最小行高
 */
@property (nonatomic, copy) ZJTextDotNumberBlock maxLineHeight;

/**
 对齐, 整形, 0为默认靠左 1为靠右 2为居中, 参考 CTTextAlignment
 */
@property (nonatomic, copy) ZJTextDotNumberBlock align;

/**
 对齐, 整形, 参考 NSLineBreakMode
 */
@property (nonatomic, copy) ZJTextDotNumberBlock lineBreakMode;

@end
