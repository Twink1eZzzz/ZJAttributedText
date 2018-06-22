//
//  ZJTextView.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/6.
//

#import <UIKit/UIKit.h>

@interface ZJTextView : UIView

/**
 传入持有的元素
 */
@property (nonatomic, strong) NSArray *elements;

/**
 传入绘制出的Layer
 */
@property (nonatomic, strong) CALayer *drawLayer;

@end
