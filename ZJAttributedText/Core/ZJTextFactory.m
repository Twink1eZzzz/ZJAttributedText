//
//  ZJTextFactory.m
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/6.
//

#import "ZJTextFactory.h"
#import <CoreText/CoreText.h>
#import "ZJTextView.h"

@implementation ZJTextFactory

+ (UIView *)textViewWithElements:(NSArray<ZJTextElement *> *)elements constraint:(CGSize)size {
    
    ZJTextView *layer = [ZJTextView new];
    layer.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    return layer;
}

@end
