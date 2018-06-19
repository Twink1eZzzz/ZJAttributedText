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
        
        //遍历所有元素
        BOOL needAdjust = NO;
        BOOL needCacheFrame = NO;
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

                //若需要垂直居中模式需要算出高度后二次调整垂直偏移
                needAdjust = needAdjust ? : [element.attributes.verticalCenter boolValue];
                
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
                    
                    //若有图片, 需要遍历CTRun获取Frame
                    needCacheFrame = YES;
                    
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
        
        //第一次试算
        CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, entireAttributedString.length), nil, paragraphSize, nil);
        
        //二次调整
        if (needAdjust) {
            for (ZJTextElement *element in elements) {
                if (element.attributes.verticalCenter) {
                    if (element.rangeValue) {
                        
                        NSRange rangeInParagraph = [element.rangeValue rangeValue];
                        
                        //计算剧种模式文字上下偏移量
                        UIFont *font = element.attributes.font ? : [UIFont systemFontOfSize:12];
                        CGFloat verticalOffset = (size.height - (font.ascender + font.descender)) / 2 + element.attributes.verticalOffset.doubleValue;
                        [entireAttributedString addAttributes:@{NSBaselineOffsetAttributeName : @(verticalOffset)} range:rangeInParagraph];
                        
                        //绘制文本实例
                        CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)entireAttributedString;
                        CFRelease(frameSetterRef);
                        frameSetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef);
                    }
                }
            }
        }
        
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
        
        //绘制文本
        CTFrameDraw(frameRef, context);
        
        if (needCacheFrame) {
            
            //缓存位置
            [self cacheFrameToElement:frameRef];
            
            for (ZJTextElement *imageElement in imageElementsArray) {
                
                CGRect imageFrame = [imageElement.frameValue CGRectValue];
                
                //垂直居中模式调整offset
                if (imageElement.attributes.verticalCenter) {
                    imageFrame.origin.y += (size.height - imageFrame.size.height) / 2;
                    
                    //调整
                    [imageElement setValue:[NSValue valueWithCGRect:imageFrame] forKey:@"frameValue"];
                }
                
                UIImage *image = imageElement.drawImage;
                CGContextDrawImage(context, imageFrame, image.CGImage);
            }
        }
        
        for (ZJTextElement *elementsss in elements) {
            
            CGRect rect = [elementsss.frameValue CGRectValue];
            NSLog(@"%@", NSStringFromCGRect(rect));
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
    
    //增加基本属性
    NSDictionary *attributesDic = [self generateAttribuesDicWithAttributesArray:@[element.attributes]];
    if (attributesDic) {
        [mutableAttributedString addAttributes:attributesDic range:NSMakeRange(0, mutableAttributedString.length)];
    }
    
    //关联元素与CTRun
    NSDictionary *attributes = @{kZJTextElementAttributeName : element};
    [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, mutableAttributedString.length)];
    
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

+ (void)cacheFrameToElement:(CTFrameRef)frame {
    
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
                CGRect imageBounds = CGRectOffset(runBounds, boxRect.origin.x, boxRect.origin.y);
                
                NSValue *boundsValue = [NSValue valueWithCGRect:imageBounds];
                
                [element setValue:boundsValue forKey:@"frameValue"];
            }
        }
    }
}

static CGFloat ascentCallback(void *ref) {
    
    ZJTextElement *element = (__bridge ZJTextElement *)ref;

    if (element.drawImage) {
        
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
    return 0;
}

static CGFloat descentCallback(void *ref) {
    
    ZJTextElement *element = (__bridge ZJTextElement *)ref;
    
    if (element.drawImage) {
        
        CGFloat offset = element.attributes.verticalOffset.doubleValue;
        return -offset;
    }
    return 0;
}

static CGFloat widthCallback(void *ref) {
    
    ZJTextElement *element = (__bridge ZJTextElement *)ref;

    if (element.drawImage) {
        
        if (element.attributes) {
            CGSize imageSize = [element.attributes.imageSizeValue CGSizeValue];
            CGFloat width = imageSize.width ? : [element.content size].width;
            return width;
        }
        return [element.content size].width;
    }
    return 0;
    
    
}

@end
