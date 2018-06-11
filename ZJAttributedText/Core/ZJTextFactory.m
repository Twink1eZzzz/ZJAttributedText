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
#import <Objc/runtime.h>

static NSString *const kZJTextImageHeight = @"kZJTextImageHeight";
static NSString *const kZJTextImageWidth = @"kZJTextImageWidth";
static NSString *const kZJTextImageAttributesAssociateKey = @"kZJTextImageAttributesAssociateKey";

#define kZJTextAttributesMapper @{\
                                  NSFontAttributeName : @"font",\
                                  NSForegroundColorAttributeName : @"color",\
                                  NSKernAttributeName : @"letterSpacing",\
                                  NSStrokeWidthAttributeName : @"strokeWidth",\
                                  NSStrokeColorAttributeName : @"strokeColor",\
                                  NSFontAttributeName : @"font",\
                                  NSVerticalGlyphFormAttributeName : @"isVertical"\
                                  }

@implementation ZJTextFactory

+ (UIView *)textViewWithElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes {
    
    ZJTextView *view = [ZJTextView new];
    view.frame = CGRectMake(0, 0, 200, 200);
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test" ofType:@"png"];
    UIImage *image2 = [UIImage imageWithContentsOfFile:imagePath];
    
    ZJTextElement *element1 = [ZJTextElement new];
    element1.content = @"test";
    
    ZJTextElement *element2 = [ZJTextElement new];
    element2.content = image2;
    ZJTextAttributes *attributes2 = [ZJTextAttributes new];
    attributes2.size = CGSizeMake(25, 25);
    element2.attributes = attributes2;
    
    ZJTextElement *element3 = [ZJTextElement new];
    UIImage *image3 = [UIImage imageWithContentsOfFile:imagePath];
    element3.content = image3;
    
    ZJTextElement *element4 = [ZJTextElement new];
    element4.content = @"test";
    ZJTextAttributes *attributes4 = [ZJTextAttributes new];
    attributes4.font = [UIFont systemFontOfSize:25];
    attributes4.color = [UIColor redColor];
    attributes4.strokeColor = [UIColor blueColor];
    attributes4.strokeWidth = @-1;
    attributes4.letterSpacing = @10;
    attributes4.isVertical = @(NO);
    
    element4.attributes = attributes4;
    
    [self drawLayer:view.layer withElements:@[element1, element2, element3, element4] defaultAttributes:nil];
    
    return view;
}

+ (void)drawLayer:(CALayer *)layer withElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes {
    
    if (!layer || !elements.count) return;
    
    //常量
    CGRect layerBounds = layer.bounds;
    CGSize layerSize = layerBounds.size;
    CGFloat height = layerSize.height;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        //组装完整字符串
        NSMutableAttributedString *entireAttributedString = [[NSMutableAttributedString alloc] init];
        NSMutableArray *imageArray = [NSMutableArray array];
        
        //遍历所有元素
        for (ZJTextElement *element in elements) {
            
            if ([element.content isKindOfClass:[NSString class]]) {
                
                //处理文本
                NSAttributedString *attributedString = [self generateAttributedStringWithContent:element.content attributes:element.attributes defaultAttributes:defaultAttributes];
                [entireAttributedString appendAttributedString:attributedString];
                
            } else {
                
                //处理非文本
                UIImage *image = nil;
                if ([element.content isKindOfClass:[UIImage class]]) {
                    image = element.content;
                } else if ([element.content isKindOfClass:[UIView class]]) {
                    image = [self drawImageWithContent:element.content];
                } else if ([element.content isKindOfClass:[CALayer class]]) {
                    image = [self drawImageWithContent:element.content];
                }
                
                if (image) {
                    
                    [imageArray addObject:image];
      
                    //设置回调
                    CTRunDelegateCallbacks callbacks;
                    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
                    callbacks.version = kCTRunDelegateVersion1;
                    callbacks.getAscent = ascentCallback;
                    callbacks.getDescent = descentCallback;
                    callbacks.getWidth = widthCallback;
                    
                    //创建代理
                    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)element); //TODO: nil测试
                    if (delegate) {
                        NSDictionary *attributes = @{(__bridge NSString *)kCTRunDelegateAttributeName : (__bridge id)delegate};
                        unichar placeHolder = 0xFFFC;
                        NSString *placeHolderString = [NSString stringWithCharacters:&placeHolder length:1];
                        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:placeHolderString attributes:attributes];
                        
                        [entireAttributedString appendAttributedString:attributedString];
                        CFRelease(delegate);
                    }
                }
            }
        }
        
        //开启图片上下文
        UIGraphicsBeginImageContextWithOptions(layerSize, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //翻转上下文
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        //绘制文本
        CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)entireAttributedString;
        CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, layerBounds);
        CFIndex length = CFAttributedStringGetLength(attributedStringRef);
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, length), path, NULL);
        CTFrameDraw(frame, context);
        
        //绘制图片
        NSArray *rectsArray = [self getRectsWithFrame:frame];
        NSInteger i = 0;
        for (UIImage *image in imageArray) {
            if (i < rectsArray.count) {
                CGRect imageFrame = [rectsArray[i] CGRectValue];
                CGContextDrawImage(context, imageFrame, image.CGImage);
                i++;
            }
        }
        
        //获取位图
        CGImageRef drawImageRef = CGBitmapContextCreateImage(context);
        UIImage *drawImage = [[UIImage alloc] initWithCGImage:drawImageRef];
        //关闭上下文
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            layer.contents = (__bridge id)drawImage.CGImage;
        });
        
        //释放内存
        CFRelease(frameSetterRef);
        CFRelease(path);
        CFRelease(frame);
    });
}

+ (UIImage *)drawImageWithContent:(id)content {
    
    UIGraphicsBeginImageContext([content frame].size);
    if ([content isKindOfClass:[CALayer class]]) {
        [content drawInContext:UIGraphicsGetCurrentContext()];
    } else {
        [content renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSAttributedString *)generateAttributedStringWithContent:(NSString *)content attributes:(ZJTextAttributes *)attributes defaultAttributes:(ZJTextAttributes *)defaultAttributes {
    
    if (!content) return nil;
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:content];
    if (!mutableAttributedString) return nil;
    
    NSDictionary *attributesDic = [self generateAttribuesDicWithAttributesArray:[NSArray arrayWithObjects:attributes, defaultAttributes, nil]];
    if (attributesDic) {
        [mutableAttributedString addAttributes:attributesDic range:NSMakeRange(0, mutableAttributedString.length)];
    }
   
    return mutableAttributedString.copy;
}

+ (NSDictionary *)generateAttribuesDicWithAttributesArray:(NSArray<ZJTextAttributes *> *)attributesArray {
    
    if (!attributesArray.count) return nil;

    NSMutableDictionary *attribuesDic = [NSMutableDictionary dictionary];
    attribuesDic[NSVerticalGlyphFormAttributeName] = @0;

    for (NSString *attributeName in kZJTextAttributesMapper) {
        NSString *propertyName = kZJTextAttributesMapper[attributeName];
        NSInteger index = 0;
        id property = nil;
        while (!property && index < attributesArray.count) {
            id attributes = attributesArray[index];
            property = [attributes valueForKey:propertyName];
            index++;
        }
        if (property) {
            attribuesDic[attributeName] = property;
        }
    }
    
    return attribuesDic.copy;
}

+ (NSArray<NSValue *> *)getRectsWithFrame:(CTFrameRef)frame {
    
    NSMutableArray *rectsArray = [NSMutableArray array];
    
    CFArrayRef linesArray = CTFrameGetLines(frame);
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
            
            ZJTextElement *element = CTRunDelegateGetRefCon(delegate);
            if (![element isKindOfClass:[ZJTextElement class]]) continue;
            
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
            
            NSValue *boundsValue = [NSValue valueWithCGRect:imageBounds];
            [rectsArray addObject:boundsValue];
        }
    }
    return rectsArray.copy;
}

static CGFloat ascentCallback(void *ref) {
    ZJTextElement *element = (__bridge ZJTextElement *)ref;
    if (element.attributes) {
        return element.attributes.size.height ? : [element.content size].height;
    }
    return [element.content size].height;
}

static CGFloat descentCallback(void *ref) {
    return 0;
}

static CGFloat widthCallback(void *ref) {
    ZJTextElement *element = (__bridge ZJTextElement *)ref;
    if (element.attributes) {
        return element.attributes.size.width ? : [element.content size].width;
    }
    return [element.content size].width;
}

@end
