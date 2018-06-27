//
//  NSString+AttributedText.m
//  ZJAttributedText
//
//  Created by Zj on 2018/6/23.
//

#import "NSString+AttributedText.h"
#import "ZJTextFactory.h"
#import "ZJTextElement.h"
#import "ZJTextAttributes.h"
#import <objc/runtime.h>

typedef void(^ZJTextElementsGenerateCompletionBlock)(NSArray *elements, ZJTextAttributes *defaultAttributes);

static NSString *const kZJTextStringAttributesAssociateKey = @"kZJTextStringAttributesAssociateKey";
static NSString *const kZJTextStringContextAssociateKey = @"kZJTextStringContextAssociateKey";
static NSString *const kZJTextStringImageAssociateKey = @"kZJTextStringImageAssociateKey";
static NSString *const kZJTextStringImagePlaceHolderPrefix = @"$ImagePlaceHolder-";
static NSString *const kZJTextStringDefaultPlaceHolderPrefix = @"$DefaultPlaceHolder-";

@implementation NSString (AttributedText)
@dynamic drawLayer;
@dynamic drawView;
@dynamic append;
@dynamic entire;

@dynamic verticalOffset;
@dynamic onClicked;
@dynamic onLayout;
@dynamic cacheFrame;
@dynamic font;
@dynamic color;
@dynamic letterSpace;
@dynamic strokeWidth;
@dynamic strokeColor;
@dynamic verticalForm;
@dynamic underline;
@dynamic imageSizeValue;
@dynamic imageAlign;
@dynamic constraintSizeValue;
@dynamic minLineSpace;
@dynamic maxLineSpace;
@dynamic minLineHeight;
@dynamic maxLineHeight;
@dynamic align;
@dynamic lineBreakMode;

#pragma mark - core method

- (ZJTextDotAppendBlock)append {
    return ^(id content) {
        if (!content) return self;
        if ([content isKindOfClass:[NSString class]]) {
            objc_setAssociatedObject(content, kZJTextStringContextAssociateKey.UTF8String, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            return (NSString *)content;
        } else if ([content isKindOfClass:[UIImage class]]) {
            NSString *placeHolder = [NSString stringWithFormat:@"%@%.0f$", kZJTextStringImagePlaceHolderPrefix, [[NSDate date] timeIntervalSince1970]];
            objc_setAssociatedObject(placeHolder, kZJTextStringImageAssociateKey.UTF8String, content, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(placeHolder, kZJTextStringContextAssociateKey.UTF8String, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            return placeHolder;
        }
        return @"";
    };
}

- (ZJTextDotEntireBlock)entire {
    return ^(void) {
        NSString *placeHolder = [NSString stringWithFormat:@"%@%.0f$", kZJTextStringDefaultPlaceHolderPrefix, [[NSDate date] timeIntervalSince1970]];
        objc_setAssociatedObject(placeHolder, kZJTextStringContextAssociateKey.UTF8String, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return placeHolder;
    };
}

- (ZJTextDotLayerDrawBlock)drawLayer {
    return ^(ZJTextLayerDrawCompletionBlock completion) {
        [self generateElementsAndDefaultAttributes:^(NSArray *elements, ZJTextAttributes *defaultAttributes) {
            [ZJTextFactory drawTextLayerWithElements:elements defaultAttributes:nil completion:^(CALayer *drawLayer) {
                if (completion) {
                    completion(drawLayer);
                }
            }];
        }];
        return self;
    };
}

- (ZJTextDotViewDrawBlock)drawView {
    return ^(ZJTextViewDrawCompletionBlock completion) {
        [self generateElementsAndDefaultAttributes:^(NSArray *elements, ZJTextAttributes *defaultAttributes) {
            [ZJTextFactory drawTextViewWithElements:elements defaultAttributes:defaultAttributes completion:^(UIView *drawView) {
                if (completion) {
                    completion(drawView);
                }
            }];
        }];
        return self;
    };
}

#pragma mark - private

- (void)setAssociate:(id)content attribute:(id)attribute forKey:(NSString *)key {
    
    if (!attribute || !key) return;
    NSMutableDictionary *attributesDic = objc_getAssociatedObject(content, kZJTextStringAttributesAssociateKey.UTF8String);
    if (!attributesDic) {
        attributesDic = [NSMutableDictionary dictionary];
    }
    
    attributesDic[key] = attribute;
    objc_setAssociatedObject(content, kZJTextStringAttributesAssociateKey.UTF8String, attributesDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)getAssociateAttributes:(id)content {
    return objc_getAssociatedObject(content, kZJTextStringAttributesAssociateKey.UTF8String);
}

- (void)generateElementsAndDefaultAttributes:(ZJTextElementsGenerateCompletionBlock)comletion {
    
    NSMutableArray *elements = [NSMutableArray array];
    ZJTextAttributes *defaultAttributes = nil;
    id content = self;
    while (content) {
        id realContent = nil;
        if ([content hasPrefix:kZJTextStringImagePlaceHolderPrefix]) {
            realContent = objc_getAssociatedObject(content, kZJTextStringImageAssociateKey.UTF8String);
        } else if ([content hasPrefix:kZJTextStringDefaultPlaceHolderPrefix]) {
            if (!defaultAttributes) {
                defaultAttributes = [ZJTextAttributes new];
            }
            NSDictionary *attibutesDic = [self getAssociateAttributes:content];
            for (NSString *key in attibutesDic) {
                [defaultAttributes setValue:attibutesDic[key] forKey:key];
            }
        } else {
            realContent = content;
        }
        
        if (realContent) {
            ZJTextElement *element = [ZJTextElement new];
            element.content = realContent;
            NSDictionary *attibutesDic = [self getAssociateAttributes:content];
            for (NSString *key in attibutesDic) {
                [element.attributes setValue:attibutesDic[key] forKey:key];
            }
            [elements insertObject:element atIndex:0];
        }
        content = objc_getAssociatedObject(content, kZJTextStringContextAssociateKey.UTF8String);
    }
    if (comletion) {
        comletion(elements, defaultAttributes);
    }
}

#pragma mark - attributes transform

- (ZJTextDotNumberBlock)verticalOffset {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"verticalOffset"];
        return self;
    };
}

- (ZJTextDotBlockBlock)onClicked {
    return ^(ZJTextZJTextAttributeCommonBlock block) {
        [self setAssociate:self attribute:block forKey:@"onClicked"];
        return self;
    };
}

- (ZJTextDotBlockBlock)onLayout {
    return ^(ZJTextZJTextAttributeCommonBlock block) {
        [self setAssociate:self attribute:block forKey:@"onLayout"];
        return self;
    };
}

- (ZJTextDotNumberBlock)cacheFrame {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"cacheFrame"];
        return self;
    };
}

- (ZJTextDotFontBlock)font {
    return ^(UIFont *font) {
        [self setAssociate:self attribute:font forKey:@"font"];
        return self;
    };
}

- (ZJTextDotColorBlock)color {
    return ^(UIColor *color) {
        [self setAssociate:self attribute:color forKey:@"color"];
        return self;
    };
}

- (ZJTextDotNumberBlock)letterSpace {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"letterSpace"];
        return self;
    };
}

- (ZJTextDotNumberBlock)strokeWidth {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"strokeWidth"];
        return self;
    };
}

- (ZJTextDotColorBlock)strokeColor {
    return ^(UIColor *color) {
        [self setAssociate:self attribute:color forKey:@"strokeColor"];
        return self;
    };
}

- (ZJTextDotNumberBlock)underline {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"underline"];
        return self;
    };
}

- (ZJTextDotValueBlock)imageSizeValue {
    return ^(NSValue *value) {
        [self setAssociate:self attribute:value forKey:@"imageSizeValue"];
        return self;
    };
}

- (ZJTextDotNumberBlock)imageAlign {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"imageAlign"];
        return self;
    };
}

- (ZJTextDotValueBlock)constraintSizeValue {
    return ^(NSValue *value) {
        [self setAssociate:self attribute:value forKey:@"constraintSizeValue"];
        return self;
    };
}

- (ZJTextDotNumberBlock)minLineSpace {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"minLineSpace"];
        return self;
    };
}

- (ZJTextDotNumberBlock)maxLineSpace {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"maxLineSpace"];
        return self;
    };
}

- (ZJTextDotNumberBlock)minLineHeight {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"minLineHeight"];
        return self;
    };
}

- (ZJTextDotNumberBlock)maxLineHeight {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"maxLineHeight"];
        return self;
    };
}

- (ZJTextDotNumberBlock)align {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"align"];
        return self;
    };
}

- (ZJTextDotNumberBlock)lineBreakMode {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"lineBreakMode"];
        return self;
    };
}

@end
