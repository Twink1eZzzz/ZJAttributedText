//
//  ZJElement.m
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/4.
//

#import "ZJTextElement.h"
#import "ZJTextAttributes.h"

@implementation ZJTextElement

- (instancetype)init {
    if (self = [super init]) {
        _attributes = [ZJTextAttributes new];
        _attributes.font = [UIFont systemFontOfSize:12];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"ZJTextAttributes: setValue: %@ forUndefinedKey: %@", value, key);
}

@end
