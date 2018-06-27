#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSString+AttributedText.h"
#import "ZJTextFactory.h"
#import "ZJTextAttributes.h"
#import "ZJTextElement.h"
#import "ZJTextLayer.h"
#import "ZJTextView.h"

FOUNDATION_EXPORT double ZJAttributedTextVersionNumber;
FOUNDATION_EXPORT const unsigned char ZJAttributedTextVersionString[];

