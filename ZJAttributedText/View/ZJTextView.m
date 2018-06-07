//
//  ZJTextView.m
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/6.
//

#import "ZJTextView.h"
#import <CoreText/CoreText.h>

@implementation ZJTextView

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //翻转上下文
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    //回调设置
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    
    NSDictionary *picDic = @{@"height" : @20,
                             @"width" : @30};
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)picDic);
    
    //图片占位
    unichar placeHolder = 0xFFFC;
    CFStringRef placeHolderString = CFStringCreateWithCharacters(kCFAllocatorSystemDefault, &placeHolder, 1);
    
    CFStringRef keys[1];
    keys[0] = kCTRunDelegateAttributeName;
    CTRunDelegateRef values[1];
    values[0] = delegate;
    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorSystemDefault, (void *)keys, (void *)values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringRef placeHolderAttributedString = CFAttributedStringCreate(kCFAllocatorSystemDefault, placeHolderString, attributes);
    CFRelease(delegate);
    
    //创建内容
    CFMutableAttributedStringRef mutableAttributeString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringRef string = CFSTR("test text\n");
    CFAttributedStringReplaceString(mutableAttributeString, CFRangeMake(0, 0), string);
    CFAttributedStringReplaceAttributedString(mutableAttributeString, CFRangeMake(CFAttributedStringGetLength(mutableAttributeString), 0), placeHolderAttributedString);
    
    //绘制
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(mutableAttributeString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    CFIndex length = CFAttributedStringGetLength(mutableAttributeString);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, length), path, NULL);
    CTFrameDraw(frame, ctx);
}

- (CGRect)getRectWithFrame:(CTFrameRef)frame {
    
    NSArray *linesArray = CTFrameGetLines(frame);
}

static CGFloat ascentCallback(void *ref) {
    return [[(__bridge NSDictionary *)ref valueForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref) {
    return 0;
}

static CGFloat widthCallback(void *ref) {
    return [[(__bridge NSDictionary *)ref valueForKey:@"width"] floatValue];
}

@end
