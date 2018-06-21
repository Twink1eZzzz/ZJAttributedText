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
static NSString *const kZJTextElementAttributeName = @"kZJTextElementAttributeName";

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

+ (void)drawTextViewWithElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes completion:(void(^)(id drawView))completion {
    
    
}

+ (void)drawTextLayerWithElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes completion:(void(^)(id drawLayer))completion {
    
    if (!elements.count) return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        //组装完整字符串
        NSMutableAttributedString *entireAttributedString = [[NSMutableAttributedString alloc] init];
        NSMutableArray *imageElementsArray = [NSMutableArray array];
     
        for (ZJTextElement *element in elements) {
            
            //若没有属性, 创建一个空属性站位
            if (!element.attributes) {
                element.attributes = [ZJTextAttributes new];
            }
            
            //合并全局属性至元素属性
            if (defaultAttributes) {
                ZJTextAttributes *combineAttributes = [self combineWithAttributesArray:@[defaultAttributes, element.attributes]];
                element.attributes = combineAttributes;
            }
            
            //处理文本
            if ([element.content isKindOfClass:[NSString class]]) {

                //生成富文本
                NSAttributedString *attributedString = [self generateAttributedStringWithStringElement:element];
                if (!attributedString) continue;
                
                //记录该段文本的位置
                NSInteger location = entireAttributedString.length;
                NSInteger length = attributedString.length;
                [element setValue:[NSValue valueWithRange:NSMakeRange(location, length)] forKey:@"rangeValue"];
                
                //拼接
                [entireAttributedString appendAttributedString:attributedString];
                
            } else {
                
                //处理非文本, 非图片其他类型则调用相关方法绘制成图片
                UIImage *image = nil;
                if ([element.content isKindOfClass:[UIImage class]]) {
                    image = element.content;
                } else if ([element.content isKindOfClass:[UIView class]]) {
                    image = [self drawImageWithContent:element.content];
                } else if ([element.content isKindOfClass:[CALayer class]]) {
                    image = [self drawImageWithContent:element.content];
                }
                
                if (image) {
                    
                    //保存绘制图片
                    element.drawImage = image;
                    
                    //储存图片元素, 后面在占位绘制图片及调整位置
                    [imageElementsArray addObject:element];
                    
                    //生成富文本
                    NSAttributedString *attributedString = [self generateAttributedStringWithImageElement:element];
                    if (!attributedString) continue;
                    
                    //保存图片位置
                    NSInteger location = entireAttributedString.length;
                    NSInteger length = attributedString.length;
                    [element setValue:[NSValue valueWithRange:NSMakeRange(location, length)] forKey:@"rangeValue"];
                    
                    //拼接
                    [entireAttributedString appendAttributedString:attributedString];
                }
            }
        }
        
        //创建CoreText相关抽象
        CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)entireAttributedString;
        CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef);
        CGSize defaultParagraphSize = [defaultAttributes.constraintSizeValue CGSizeValue];
        CGSize paragraphSize = CGSizeEqualToSize(defaultParagraphSize, CGSizeZero) ? CGSizeMake(MAXFLOAT, MAXFLOAT) : defaultParagraphSize;
        
        //试算
        CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, entireAttributedString.length), nil, paragraphSize, nil);
        
        //生成相关路径->CTFrame
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

        //缓存位置
        [self cacheFrameToElementIfNeeded:frameRef size:size];

        //绘制图片
        for (ZJTextElement *imageElement in imageElementsArray) {
            
            NSArray *frameValueArray = imageElement.drawFrameValueArray;
            CGRect imageFrame = [[frameValueArray firstObject] CGRectValue];
            
            UIImage *image = imageElement.drawImage;
            CGContextDrawImage(context, imageFrame, image.CGImage);
        }
        
        //绘制文本
        CTFrameDraw(frameRef, context);
        
        //获取位图
        CGImageRef drawImageRef = CGBitmapContextCreateImage(context);
        UIImage *drawImage = [[UIImage alloc] initWithCGImage:drawImageRef];
        
        //关闭上下文
        UIGraphicsEndImageContext();
        
        //主线程生成Layer
        dispatch_async(dispatch_get_main_queue(), ^{
            CALayer *layer = [CALayer layer];
            layer.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1].CGColor;
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
    
    //根据传入属性对象数组合并出一个新的属性对象. 按数组下表为属性取值优先级
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
    
    //将不同类型内容绘制为图片
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

+ (NSAttributedString *)generateAttributedStringWithStringElement:(ZJTextElement *)element {
    
    if (!element || !element.content || ![element.content isKindOfClass:[NSString class]]) return nil;
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:element.content];
    if (!mutableAttributedString) return nil;
    
    NSRange range = NSMakeRange(0, mutableAttributedString.length);
    
    //增加基本属性
    NSDictionary *attributesDic = [self generateAttribuesDicWithAttributesArray:@[element.attributes]];
    if (attributesDic) {
        [mutableAttributedString addAttributes:attributesDic range:range];
    }
    
    //关联元素与CTRun
    NSDictionary *attributes = @{kZJTextElementAttributeName : element};
    [mutableAttributedString addAttributes:attributes range:range];
    
    return mutableAttributedString.copy;
}

+ (NSDictionary *)generateAttribuesDicWithAttributesArray:(NSArray<ZJTextAttributes *> *)attributesArray {
    
    if (!attributesArray.count) return nil;

    //遍历所有基本属性, 生成属性字典
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

+ (NSAttributedString *)generateAttributedStringWithImageElement:(ZJTextElement *)element {
    
     if (!element || !element.content || !element.drawImage) return nil;
    
    //设置回调
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    
    //创建代理
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)element);
    if (delegate) {
        NSDictionary *attributes = @{(__bridge NSString *)kCTRunDelegateAttributeName : (__bridge id)delegate,
                                     kZJTextElementAttributeName : element};
        unichar placeHolder = 0xFFFC;
        NSString *placeHolderString = [NSString stringWithCharacters:&placeHolder length:1];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:placeHolderString attributes:attributes];
        CFRelease(delegate);
        
        return attributedString.copy;
    }
    return nil;
}

+ (void)cacheFrameToElementIfNeeded:(CTFrameRef)frame size:(CGSize)size {
    
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
            
            //是否必要计算
            BOOL needCaculate = YES;
            ZJTextElement *element = CFDictionaryGetValue(attributes, (__bridge CFStringRef)kZJTextElementAttributeName);
            if (element) {
                needCaculate = (BOOL)CFDictionaryGetValue(attributes, kCTRunDelegateAttributeName); //图片
                needCaculate = needCaculate ? : (BOOL)element.attributes.onClicked; //可点击
                needCaculate = needCaculate ? : element.attributes.cacheFrame.boolValue; //是否外部需要计算
            } else {
                needCaculate = NO;
            }
            
            if (needCaculate) {
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
                
                //绘制的基础frame
                CGRect bounds = CGRectOffset(runBounds, boxRect.origin.x, boxRect.origin.y);
                NSValue *frameValue = [NSValue valueWithCGRect:bounds];
                
                NSArray *drawFrameValueArray = element.drawFrameValueArray;
                if (!drawFrameValueArray) {
                    drawFrameValueArray = @[frameValue];
                } else {
                    drawFrameValueArray = [drawFrameValueArray arrayByAddingObject:frameValue];
                }
                [element setValue:drawFrameValueArray forKey:@"drawFrameValueArray"];
                
                //显示的frame: 由绘制的基础frame->翻转得到
                CGFloat overY = bounds.origin.y;
                overY = size.height - overY - bounds.size.height;
                CGRect overBounds = CGRectMake(bounds.origin.x, overY, bounds.size.width, bounds.size.height);
                NSValue *overFrameValue = [NSValue valueWithCGRect:overBounds];
                
                NSArray *frameValueArray = element.frameValueArray;
                if (!frameValueArray) {
                    frameValueArray = @[overFrameValue];
                } else {
                    frameValueArray = [frameValueArray arrayByAddingObject:overFrameValue];
                }
                [element setValue:frameValueArray forKey:@"frameValueArray"];
            }
        }
    }
}

static CGFloat ascentCallback(void *ref) {
    
    ZJTextElement *element = (__bridge ZJTextElement *)ref;
    CGFloat ascent = 0;
    if (element.drawImage) {
        CGFloat height = 0;
        if (element.attributes && element.attributes.imageSizeValue) {
            CGSize imageSize = [element.attributes.imageSizeValue CGSizeValue];
            height = imageSize.height;
        } else {
            height = [element.drawImage size].height / [UIScreen mainScreen].scale;
        }
        UIFont *font = [UIFont systemFontOfSize:12];
        CGFloat fontDescent = fabs(font.descender);
        CGFloat fontAscent = fabs(font.ascender);
        CGFloat fontHeight = (fontDescent + fontAscent);
        ascent = (height - fontHeight) / 2 + fabs(font.ascender);
        if (element.attributes.verticalOffset) {
            ascent += element.attributes.verticalOffset.doubleValue;
        }
    }
    return ascent;
}

static CGFloat descentCallback(void *ref) {
    
    ZJTextElement *element = (__bridge ZJTextElement *)ref;
    CGFloat descent = 0;
    if (element.drawImage) {
        CGFloat height = 0;
        if (element.attributes && element.attributes.imageSizeValue) {
            CGSize imageSize = [element.attributes.imageSizeValue CGSizeValue];
            height = imageSize.height;
        } else {
            height = [element.drawImage size].height / [UIScreen mainScreen].scale;
        }
        UIFont *font = [UIFont systemFontOfSize:12];
        CGFloat fontDescent = fabs(font.descender);
        CGFloat fontAscent = fabs(font.ascender);
        CGFloat fontHeight = (fontDescent + fontAscent);
        descent = (height - fontHeight) / 2 + fabs(font.descender);
        if (element.attributes.verticalOffset) {
            descent -= element.attributes.verticalOffset.doubleValue;
        }
    }
    return descent;
}

static CGFloat widthCallback(void *ref) {
    
    ZJTextElement *element = (__bridge ZJTextElement *)ref;
    if (element.drawImage) {
        CGFloat originWidth = [element.drawImage size].width / [UIScreen mainScreen].scale;
        if (element.attributes && element.attributes.imageSizeValue) {
            CGSize imageSize = [element.attributes.imageSizeValue CGSizeValue];
            CGFloat width = imageSize.width;
            return width;
        }
        return originWidth;
    }
    return 0;
}

@end
