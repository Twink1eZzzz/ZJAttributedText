//
//  ZJTextLayer.m
//  ZJAttributedText
//
//  Created by Zj on 2018/6/23.
//

#import "ZJTextLayer.h"
#import "ZJTextElement.h"
#import "ZJTextAttributes.h"

@implementation ZJTextLayer

- (void)layoutSublayers {
    [super layoutSublayers];
    
    for (ZJTextElement *element in _elements) {
        if (element.attributes.onLayout) {
            element.attributes.onLayout();
        }
    }
}

@end
