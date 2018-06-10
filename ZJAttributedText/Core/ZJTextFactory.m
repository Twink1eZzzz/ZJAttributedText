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

+ (UIView *)textViewWithElements:(NSArray<ZJTextElement *> *)elements defaultAttribute:(ZJTextAttributes *)attributes {
    
    ZJTextView *layer = [ZJTextView new];
    return layer;
}

@end
