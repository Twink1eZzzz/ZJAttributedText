//
//  ZJElement.m
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/4.
//

#import "ZJTextElement.h"
#import "ZJTextAttributes.h"

@interface ZJTextElement()
@property (nonatomic, strong) NSAttributedString *attributedString;
@property (nonatomic, strong) ZJTextAttributes *defaultAttributes;

@end

@implementation ZJTextElement

#pragma mark - public

- (NSAttributedString *)generateAttributedStringWithDefaultAttributes:(ZJTextAttributes *)defaultAttributes ignoredCache:(BOOL)ignored {
    
    _defaultAttributes = defaultAttributes;
    
    if (ignored) {
        _attributedString = nil;
    }
    
    if (!_attributedString && _content) {
        
        NSMutableAttributedString *mutableAttributedString = nil;
        if ([_content isKindOfClass:[NSString class]]) {
            mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:_content];
        } else if ([_content isKindOfClass:[UIImage class]]) {
            mutableAttributedString = [self attributedStringWithImage:_content];
        } else if ([_content isKindOfClass:[UIView class]]) {
            UIImage *image = [self drawImageWithContent:_content];
            mutableAttributedString = [self attributedStringWithImage:image];
        } else if ([_content isKindOfClass:[CALayer class]]) {
            UIImage *image = [self drawImageWithContent:_content];
            mutableAttributedString = [self attributedStringWithImage:image];
        }
        
        if (!mutableAttributedString) return nil;
        NSDictionary *attributesDic = [self generateAttribuesDic];
        [mutableAttributedString addAttributes:attributesDic range:NSMakeRange(0, mutableAttributedString.length)];
        
        _attributedString = mutableAttributedString.copy;
    }
    return _attributedString;
}

- (NSAttributedString *)regenerateAttributedString {
    return [self generateAttributedStringWithDefaultAttributes:_defaultAttributes ignoredCache:YES];
}

#pragma mark - private

- (NSMutableAttributedString *)attributedStringWithImage:(UIImage *)image {
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = _content;
    CGSize imageSize = CGSizeEqualToSize(_attributes.imageSize, CGSizeZero) ? _defaultAttributes.imageSize : _attributes.imageSize;
    if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
        imageSize = image.size;
    }
    attachment.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    return [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
}

- (UIImage *)drawImageWithContent:(id)content {
    
    UIGraphicsBeginImageContext([_content frame].size);
    if ([_content isKindOfClass:[CALayer class]]) {
        [_content drawInContext:UIGraphicsGetCurrentContext()];
    } else {
        [_content renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (NSDictionary *)generateAttribuesDic {
    
    NSMutableDictionary *attribuesDic = [NSMutableDictionary dictionary];
    
    UIFont *font = _attributes.font ? : _defaultAttributes.font;
    if (font) {
        attribuesDic[NSFontAttributeName] = font;
    }
    
    UIColor *color = _attributes.color ? : _defaultAttributes.color;
    if (color) {
        attribuesDic[NSForegroundColorAttributeName] = color;
    }
    
    NSNumber *letterSpacing = _attributes.letterSpacing ? : _defaultAttributes.letterSpacing;
    if (letterSpacing) {
        attribuesDic[NSKernAttributeName] = letterSpacing;
    }
    
    NSNumber *obliquity = _attributes.obliquity ? : _defaultAttributes.obliquity;
    if (obliquity) {
        attribuesDic[NSObliquenessAttributeName] = obliquity;
    }
    
    NSNumber *flat = _attributes.flat ? : _defaultAttributes.flat;
    if (flat) {
        attribuesDic[NSExpansionAttributeName] = flat;
    }
    
    NSNumber *strokeWidth = _attributes.strokeWidth ? : _defaultAttributes.strokeWidth;
    if (strokeWidth) {
        attribuesDic[NSStrokeWidthAttributeName] = strokeWidth;
    }
    
    UIColor *strokeColor = _attributes.strokeColor ? : _defaultAttributes.strokeColor;
    if (strokeColor) {
        attribuesDic[NSStrokeColorAttributeName] = strokeColor;
    }
    
    NSShadow *shadow = _attributes.shadow ? : _defaultAttributes.shadow;
    if (shadow) {
        attribuesDic[NSShadowAttributeName] = shadow;
        if (!obliquity && !flat) {
            attribuesDic[NSVerticalGlyphFormAttributeName] = @0;
        }
    }
    
    return attribuesDic.copy;
}

@end
