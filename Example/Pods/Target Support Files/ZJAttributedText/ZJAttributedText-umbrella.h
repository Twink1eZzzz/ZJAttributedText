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

#import "ZJTextFactory.h"
#import "ZJTextStyleParser.h"
#import "ZJTextAttribute.h"
#import "ZJTextElement.h"
#import "ZJTextParagraph.h"
#import "ZJTextStyle.h"
#import "ZJTextLayer.h"
#import "ZJTextView.h"

FOUNDATION_EXPORT double ZJAttributedTextVersionNumber;
FOUNDATION_EXPORT const unsigned char ZJAttributedTextVersionString[];

