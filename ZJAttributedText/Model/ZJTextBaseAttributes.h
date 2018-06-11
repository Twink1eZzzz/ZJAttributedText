//
//  ZJTextBaseAttributes.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/11.
//

#import <Foundation/Foundation.h>

@interface ZJTextBaseAttributes : NSObject
#pragma mark - not supported

/**
 点击变色
 */
//@property (nonatomic, assign, getter=isHighlightEnable) BOOL highlightEnable;

/**
 当挂载或者布局变化以后调用
 */
//@property (nonatomic, copy) OnLayloutBlock onLayout;

/**
 当文本被点击以后调用此回调函数
 */
//@property (nonatomic, copy) OnPressBlock onPress;

/**
 用来当文本过长的时候裁剪文本。包括折叠产生的换行在内，总的行数不会超过这个属性的限制
 */
//@property (nonatomic, assign) NSInteger numberOfLines;



/**
 垂直偏移
 */
//@property (nonatomic, strong) NSNumber *verticalOffset;


/**
 行高
 */
//@property (nonatomic, strong) NSNumber *lineHeight;

/**
 阴影颜色
 */
//@property (nonatomic, strong) UIColor *shadowColor;

/**
 阴影偏移
 */
//@property (nonatomic, assign) CGSize shadowOffset;

/**
 约束尺寸
 */
//@property (nonatomic, assign) CGRect constaintSize;

@end
