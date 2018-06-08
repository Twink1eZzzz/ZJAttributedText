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
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    CGRect imageFrame = [self getRectWithFrame:frame];
    CGContextDrawImage(ctx, imageFrame, image.CGImage);
    
    CFRelease(delegate);
    CFRelease(placeHolderString);
    CFRelease(attributes);
    CFRelease(placeHolderAttributedString);
    CFRelease(mutableAttributeString);
    CFRelease(string);
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
}

- (CGRect)getRectWithFrame:(CTFrameRef)frame {
    
    CFArrayRef linesArray = CTFrameGetLines(frame);\
    CFIndex linesCount = CFArrayGetCount(linesArray);
    CGPoint points[linesCount];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);
    
    //遍历CTLine
    for (CFIndex i = 0; i < linesCount; i++) {
        
        CTLineRef line = CFArrayGetValueAtIndex(linesArray, i);
        CFArrayRef runsArray = CTLineGetGlyphRuns(line);
        CFIndex runsCount = CFArrayGetCount(runsArray);
        
        //遍历CTRun
        for (CFIndex j = 0; j < runsCount; j++) {
            
            CTRunRef run = CFArrayGetValueAtIndex(runsArray, j);
            CFDictionaryRef attributes = CTRunGetAttributes(run);
            CTRunDelegateRef delegate = CFDictionaryGetValue(attributes, kCTRunDelegateAttributeName);
            if (!delegate) continue;
            
            CFDictionaryRef config = CTRunDelegateGetRefCon(delegate);
            if (!config || CFGetTypeID(config) != CFDictionaryGetTypeID()) continue;
            
            CGPoint point = points[i];
            CGFloat ascent;
            CGFloat descent;
            CGRect runBounds;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            CGFloat offsetX = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = point.x + offsetX;
            runBounds.origin.y = point.y - descent;
            CGPathRef path = CTFrameGetPath(frame);
            CGRect boxRect = CGPathGetBoundingBox(path);
            CGRect imageBounds = CGRectOffset(runBounds, boxRect.origin.x, boxRect.origin.y);
            return imageBounds;
        }
    }
    return CGRectZero;
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
