//
//  ZJTextAttributes.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/11.
//

#import <Foundation/Foundation.h>

@interface ZJTextAttributes : NSObject

#pragma mark - string attributes

/**
 颜色
 */
@property (nonatomic, strong) UIColor *color;

/**
 字体
 */
@property (nonatomic, strong) UIFont *font;

/**
 字间距
 */
@property (nonatomic, strong) NSNumber *letterSpacing;

/**
 描边宽度, 整数为镂空, Color不生效; 负数Color生效
 */
@property (nonatomic, strong) NSNumber *strokeWidth;

/**
 描边颜色
 */
@property (nonatomic, strong) UIColor *strokeColor;

/**
 是否是纵向, 默认NO
 */
@property (nonatomic, strong) NSNumber *isVertical;

///**
// 斜体倾斜值
// */
//@property (nonatomic, strong) NSNumber *obliquity;
//
///**
// 扁平值
// */
//@property (nonatomic, strong) NSNumber *flat;
//
///**
// 阴影
// */
//@property (nonatomic, strong) NSShadow *shadow;

#pragma mark - image attributes

/**
 尺寸
 */
@property (nonatomic, assign) CGSize size;

@end
