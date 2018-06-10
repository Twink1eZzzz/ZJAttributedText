//
//  ZJTextFactory.m
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/6.
//

#import "ZJTextFactory.h"
#import <CoreText/CoreText.h>
#import "ZJTextView.h"
#import "ZJTextElement.h"
#import "ZJTextAttributes.h"

static NSString *const kZJTextImageHeight = @"kZJTextImageHeight";
static NSString *const kZJTextImageWidth = @"kZJTextImageWidth";

@implementation ZJTextFactory

+ (UIView *)textViewWithElements:(NSArray<ZJTextElement *> *)elements defaultAttribute:(ZJTextAttributes *)attributes {
    
    ZJTextView *view = [ZJTextView new];
    view.frame = CGRectMake(0, 0, 100, 100);
    
    ZJTextElement *element1 = [ZJTextElement new];
    element1.content = @"test";
    ZJTextElement *element2 = [ZJTextElement new];
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    element2.content = image;
    
    [self drawLayer:view.layer withElements:@[element1, element2] defaultAttribute:nil];
    
    return view;
}

+ (void)drawLayer:(CALayer *)layer withElements:(NSArray<ZJTextElement *> *)elements defaultAttribute:(ZJTextAttributes *)defaultAttribute {
    
    if (!layer || !elements.count) return;
    
    //常量
    CGRect layerBounds = layer.bounds;
    CGSize layerSize = layerBounds.size;
    CGFloat height = layerSize.height;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        //组装完整字符串
        NSMutableAttributedString *entireAttributedString = [[NSMutableAttributedString alloc] init];
        for (ZJTextElement *element in elements) {
            [entireAttributedString appendAttributedString:[element generateAttributedStringWithDefaultAttributes:defaultAttribute ignoredCache:NO]];
        }
        
        //回调设置
        //    CTRunDelegateCallbacks callbacks;
        //    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
        //    callbacks.version = kCTRunDelegateVersion1;
        //    callbacks.getAscent = ascentCallback;
        //    callbacks.getDescent = descentCallback;
        //    callbacks.getWidth = widthCallback;
        //
        //    NSDictionary *picDic = @{kZJTextImageHeight : @14,
        //                             kZJTextImageWidth : @14};
        //    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)picDic);
        
        //图片占位
        //    unichar placeHolder = 0xFFFC;
        //    CFStringRef placeHolderString = CFStringCreateWithCharacters(kCFAllocatorSystemDefault, &placeHolder, 1);
        //    CFStringRef keys[1];
        //    keys[0] = kCTRunDelegateAttributeName;
        //    CTRunDelegateRef values[1];
        //    values[0] = delegate;
        //    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorSystemDefault, (void *)keys, (void *)values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        //    CFAttributedStringRef placeHolderAttributedString = CFAttributedStringCreate(kCFAllocatorSystemDefault, placeHolderString, attributes);
        //    CFRelease(placeHolderString);
        //    CFRelease(placeHolderAttributedString);
        //    CFRelease(delegate);
        
        //创建内容
//        CFMutableAttributedStringRef mutableAttributeString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
//        CFStringRef string = CFSTR("test text");
//        CFAttributedStringReplaceString(mutableAttributeString, CFRangeMake(0, 0), string);
        //    CFAttributedStringReplaceAttributedString(mutableAttributeString, CFRangeMake(CFAttributedStringGetLength(mutableAttributeString), 0), placeHolderAttributedString);
        
        //开启图片上下文
        UIGraphicsBeginImageContext(layerSize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //翻转上下文
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        //绘制
        CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)entireAttributedString;
        CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, layerBounds);
        CFIndex length = CFAttributedStringGetLength(attributedStringRef);
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, length), path, NULL);
        CTFrameDraw(frame, context);
        
        //    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test" ofType:@"png"];
        //    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        //    CGRect imageFrame = [self getRectWithFrame:frame];
        //    CGContextDrawImage(ctx, imageFrame, image.CGImage);
        
        //释放内存
//        CFRelease(attributes);
//        CFRelease(mutableAttributeString);
        CFRelease(frameSetterRef);
//        CFRelease(st ring);
        CFRelease(path);
        CFRelease(frame);
        
        //获取位图
        CGImageRef drawImageRef = CGBitmapContextCreateImage(context);
        UIImage *drawImage = [[UIImage alloc] initWithCGImage:drawImageRef];
        //关闭上下文
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            layer.contents = (__bridge id)drawImage.CGImage;
        });
    });
}

//static CGFloat ascentCallback(void *ref) {
//    return [[(__bridge NSDictionary *)ref valueForKey:kZJTextImageHeight] floatValue];
//}
//
//static CGFloat descentCallback(void *ref) {
//    return 0;
//}
//
//static CGFloat widthCallback(void *ref) {
//    return [[(__bridge NSDictionary *)ref valueForKey:kZJTextImageWidth] floatValue];
//}

@end
