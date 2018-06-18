//
//  ZJTextAttributes.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/11.
//

#import <Foundation/Foundation.h>

@interface ZJTextAttributes : NSObject

#pragma mark - common attributes

/**
 竖直方向偏移
 */
@property (nonatomic, strong) NSNumber *verticalOffset;

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

/**
 文字是否自动垂直居中
 */
@property (nonatomic, strong) NSNumber *verticalCenter;

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
 图片尺寸, 默认为图片本身尺寸
 */
@property (nonatomic, strong) NSValue *imageSizeValue;

#pragma mark - paragraph attributes

/**
 段落尺寸, 只在defaultAttributes生效, 默认Maxfloat
 */
@property (nonatomic, strong) NSValue *paragraphSizeValue;

@end
