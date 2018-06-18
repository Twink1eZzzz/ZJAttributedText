//
//  ZJTextFactory.m
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/6.
//

#import "ZJTextFactory.h"
#import <CoreText/CoreText.h>
#import "ZJTextLayer.h"
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
NSVerticalGlyphFormAttributeName : @"isVertical",\
NSBaselineOffsetAttributeName : @"verticalOffset"\
}

@implementation ZJTextFactory

+ (void)drawTextLayerWithElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes completion:(ZJAttributesTextDrawCompletionBlock)completion {
    
    if (!elements.count) return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        //组装完整字符串
        NSMutableAttributedString *entireAttributedString = [[NSMutableAttributedString alloc] init];
        NSMutableArray *imageElementsArray = [NSMutableArray array];
        
        //遍历所有元素
        BOOL needAdjust = NO;
        for (ZJTextElement *element in elements) {
            
            if (!element.attributes) {
                element.attributes = [ZJTextAttributes new];
            }
            
            if (defaultAttributes) {
                ZJTextAttributes *combineAttributes = [self combineWithAttributesArray:@[defaultAttributes, element.attributes]];
                element.attributes = combineAttributes;
            }
            
            if ([element.content isKindOfClass:[NSString class]]) {

                needAdjust = needAdjust ? : [element.attributes.verticalCenter boolValue];
                
                //处理文本
                NSAttributedString *attributedString = [self generateAttributedStringWithContent:element.content attributes:element.attributes];
                
                NSInteger location = entireAttributedString.length;
                NSInteger length = attributedString.length;
                element.rangeInParagraph = NSMakeRange(location, length);
                
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
                    
                    element.drawImage = image;
                    
                    NSInteger location = entireAttributedString.length + 1;
                    NSInteger length = 1;
                    element.rangeInParagraph = NSMakeRange(location, length);
                    
                    [imageElementsArray addObject:element];
                    
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
        
        //绘制文本
        CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)entireAttributedString;
        CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef);
        CGSize defaultParagraphSize = [defaultAttributes.paragraphSizeValue CGSizeValue];
        CGSize paragraphSize = CGSizeEqualToSize(defaultParagraphSize, CGSizeZero) ? CGSizeMake(MAXFLOAT, MAXFLOAT) : defaultParagraphSize;
        CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, entireAttributedString.length), nil, paragraphSize, nil);
        
        //二次调整
        if (needAdjust) {
            for (ZJTextElement *element in elements) {
                if (element.attributes.verticalCenter) {
                    if (element.rangeInParagraph.length && element.rangeInParagraph.location + element.rangeInParagraph.length <= entireAttributedString.length) {
                        UIFont *font = element.attributes.font ? : [UIFont systemFontOfSize:12];
                        CGFloat verticalOffset = (size.height - (font.ascender + font.descender)) / 2 + element.attributes.verticalOffset.doubleValue;
                        [entireAttributedString addAttributes:@{NSBaselineOffsetAttributeName : @(verticalOffset)} range:element.rangeInParagraph];
                        
                        //绘制文本
                        CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)entireAttributedString;
                        CFRelease(frameSetterRef);
                        frameSetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef);
                        //size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, entireAttributedString.length), nil, paragraphSize, nil);
                    }
                }
            }
        }
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CFIndex length = CFAttributedStringGetLength(attributedStringRef);
        CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, length), path, NULL);
        
        //开启图片上下文
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //翻转上下文
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CTFrameDraw(frameRef, context);
        
        //绘制图片
        NSArray *rectsArray = [self getRectsWithFrame:frameRef];
        NSInteger i = 0;
        for (ZJTextElement *imageElement in imageElementsArray) {
            if (i < rectsArray.count) {
                CGRect imageFrame = [rectsArray[i] CGRectValue];
                
                if (imageElement.attributes.verticalCenter) {
                    imageFrame.origin.y += (size.height - imageFrame.size.height) / 2;
                }
                
                UIImage *image = imageElement.drawImage;
                CGContextDrawImage(context, imageFrame, image.CGImage);
                i++;
            }
        }
        
        //获取位图
        CGImageRef drawImageRef = CGBitmapContextCreateImage(context);
        UIImage *drawImage = [[UIImage alloc] initWithCGImage:drawImageRef];
        
        //关闭上下文
        UIGraphicsEndImageContext();
        
        //主线程生成Layer
        dispatch_async(dispatch_get_main_queue(), ^{
            CALayer *layer = [CALayer layer];
            layer.frame = CGRectMake(0, 0, size.width, size.height);
            layer.contents = (__bridge id)drawImage.CGImage;
            if (completion) {
                completion(layer);
            }
        });
        
        //释放内存
        CFRelease(frameSetterRef);
        CFRelease(path);
        CFRelease(frameRef);
    });
}

+ (ZJTextAttributes *)combineWithAttributesArray:(NSArray<ZJTextAttributes *> *)attributesArray {
    
    ZJTextAttributes *combineAttributes = [ZJTextAttributes new];
    
    Class class = [ZJTextAttributes class];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(class, &count);
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
        id value = nil;
        for (ZJTextAttributes *attributes in attributesArray) {
            value = [attributes valueForKey:key];
            if (value) {
                [combineAttributes setValue:value forKey:key];
                break;
            }
        }
    }
    return combineAttributes;
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

+ (NSAttributedString *)generateAttributedStringWithContent:(NSString *)content attributes:(ZJTextAttributes *)attributes {
    
    if (!content) return nil;
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:content];
    if (!mutableAttributedString) return nil;
    
    //增加基本属性
    NSDictionary *attributesDic = [self generateAttribuesDicWithAttributesArray:@[attributes]];
    if (attributesDic) {
        [mutableAttributedString addAttributes:attributesDic range:NSMakeRange(0, mutableAttributedString.length)];
    }
    
    return mutableAttributedString.copy;
}

+ (NSDictionary *)generateAttribuesDicWithAttributesArray:(NSArray<ZJTextAttributes *> *)attributesArray {
    
    if (!attributesArray.count) return nil;

    NSMutableDictionary *attribuesDic = [NSMutableDictionary dictionary];
    
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
        CGSize imageSize = [element.attributes.imageSizeValue CGSizeValue];
        CGFloat height = imageSize.height ? : [element.content size].height;
        CGFloat ascent = height;
        if (element.attributes.verticalOffset) {
            ascent += element.attributes.verticalOffset.doubleValue;
        }
        return ascent;
    }
    return [element.content size].height;
}

static CGFloat descentCallback(void *ref) {
    ZJTextElement *element = (__bridge ZJTextElement *)ref;
    CGFloat offset = element.attributes.verticalOffset.doubleValue;
    return -offset;
}

static CGFloat widthCallback(void *ref) {
    ZJTextElement *element = (__bridge ZJTextElement *)ref;
    if (element.attributes) {
        CGSize imageSize = [element.attributes.imageSizeValue CGSizeValue];
        CGFloat width = imageSize.width ? : [element.content size].width;
        return width;
    }
    return [element.content size].width;
}

@end
