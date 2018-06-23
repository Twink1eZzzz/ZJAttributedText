//
//  ZJTextAttributes.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/11.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZJTextImageAlign) {
    ZJTextImageAlignBottomToBaseLine = 0,         //图片底部对齐基准线
    ZJTextImageAlignCenterToFont                  //图片居中向特定字体对齐, 需要设置 font 属性, 若没有为系统12号字体
};

typedef void(^ZJTextZJTextAttributeOnClickedBlock)(void);

@interface ZJTextAttributes : NSObject

#pragma mark - common attributes

/**
 竖直方向偏移
 */
@property (nonatomic, strong) NSNumber *verticalOffset;

/**
 点击Block
 */
@property (nonatomic, copy) ZJTextZJTextAttributeOnClickedBlock onClicked;

/**
 是否缓存frame, 会计算文本在整段富文本中的frame
 */
@property (nonatomic, strong) NSNumber *cacheFrame;

#pragma mark - string attributes

/**
 字体: 文字字体/图片居中对齐字体
 */
@property (nonatomic, strong) UIFont *font;

/**
 颜色
 */
@property (nonatomic, strong) UIColor *color;

/**
 字间距
 */
@property (nonatomic, strong) NSNumber *letterSpace;

/**
 描边宽度, 整数为镂空, Color不生效; 负数Color生效
 */
@property (nonatomic, strong) NSNumber *strokeWidth;

/**
 描边颜色
 */
@property (nonatomic, strong) UIColor *strokeColor;

/**
 文字绘制随文字书写方向, 默认 否(0), 是(非0)
 */
@property (nonatomic, strong) NSNumber *verticalForm;

/**
 下划线类型, 整形, 0为none, 1为细线 2为加粗 9为双条 参考 CTUnderlineStyle(仅枚举了三种, 其他值也有不同效果)
 */
@property (nonatomic, strong) NSNumber *underline;

#pragma mark - image attributes

/**
 图片尺寸, 默认为图片本身尺寸
 */
@property (nonatomic, strong) NSValue *imageSizeValue;

/**
 图片对齐模式 参看 ZJTextImageAlign
 */
@property (nonatomic, strong) NSNumber *imageAlign;

#pragma mark - paragraph attributes

/**
 绘制的约束尺寸, 默认Max
 */
@property (nonatomic, strong) NSValue *constraintSizeValue;

/**
 最小行间距
 */
@property (nonatomic, strong) NSNumber *minLineSpace;

/**
 最大行间距
 */
@property (nonatomic, strong) NSNumber *maxLineSpace;

/**
 最小行高
 */
@property (nonatomic, strong) NSNumber *minLineHeight;

/**
 最小行高
 */
@property (nonatomic, strong) NSNumber *maxLineHeight;

/**
 对齐, 整形, 0为默认靠左 1为居中 2为靠右, 参考 NSTextAlignment
 */
@property (nonatomic, strong) NSNumber *align;

@end
