//
//  ZJTextAttributes.m
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/11.
//

#import "ZJTextAttributes.h"

@implementation ZJTextAttributes

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"ZJTextAttributes: setValue: %@ forUndefinedKey: %@", value, key);
}

@end
