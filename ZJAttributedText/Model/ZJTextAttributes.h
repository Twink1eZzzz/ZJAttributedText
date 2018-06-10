//
//  ZJTextAttribute.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/6.
//

#import <UIKit/UIKit.h>

typedef void(^OnLayloutBlock)(CGRect frame);
typedef void(^OnPressBlock)(void);

@interface ZJTextAttributes : NSObject

#pragma mark - supported


#pragma mark - not supported

/**
 点击变色
 */
@property (nonatomic, assign, getter=isHighlightEnable) BOOL highlightEnable;

/**
 当挂载或者布局变化以后调用
 */
@property (nonatomic, copy) OnLayloutBlock onLayout;

/**
 当文本被点击以后调用此回调函数
 */
@property (nonatomic, copy) OnPressBlock onPress;

/**
 用来当文本过长的时候裁剪文本。包括折叠产生的换行在内，总的行数不会超过这个属性的限制
 */
@property (nonatomic, assign) NSInteger numberOfLines;

/**
 颜色
 */
@property (nonatomic, strong) UIColor *color;

/**
 字体
 */
@property (nonatomic, strong) UIFont *font;

/**
 垂直偏移
 */
@property (nonatomic, assign) CGFloat verticalOffset;

/**
 字间距
 */
@property (nonatomic, assign) CGFloat letterSpacing;

/**
 行高
 */
@property (nonatomic, assign) CGFloat lineHeight;

/**
 阴影颜色
 */
@property (nonatomic, strong) UIColor *shadowColor;

/**
 阴影偏移
 */
@property (nonatomic, assign) CGSize shadowOffset;

/**
 约束尺寸
 */
@property (nonatomic, assign) CGRect constaintSize;

@end
