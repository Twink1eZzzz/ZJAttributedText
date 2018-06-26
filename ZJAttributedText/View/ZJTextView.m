//
//  ZJTextView.m
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/6.
//

#import "ZJTextView.h"
#import "ZJTextElement.h"
#import "ZJTextAttributes.h"

@implementation ZJTextView

#pragma mark - life Cycle

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _drawLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

#pragma mark - user Iteraction

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    
    [self respondsWithPoint:point];
}

#pragma mark - public

- (void)setDrawLayer:(CALayer *)drawLayer {
    _drawLayer = drawLayer;
    
    [self.layer addSublayer:_drawLayer];
}

#pragma mark - private

- (void)respondsWithPoint:(CGPoint)point {
    
    for (ZJTextElement *element in _elements) {
        if (!element.attributes.onClicked) {
            continue;
        } else {
            for (NSValue *frameValue in element.frameValueArray) {
                if (CGRectContainsPoint(frameValue.CGRectValue, point)) {
                    element.attributes.onClicked(element);
                }
            }
        }
    }
}

@end
