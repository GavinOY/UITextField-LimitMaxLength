//
//  UITextField+LimitMaxLength.h
//
//  Created by oyzhx on 16/7/21.
//  Copyright © 2016年 oyzhx. All rights reserved.
//

#import "UITextField+LimitMaxLength.h"
#import <objc/runtime.h>

@implementation UITextField (LimitMaxLength)

static NSString *kTextMaxLengthKey = @"kTextMaxLengthKey";
static NSString *kEditEndBlockKey = @"kEditEndBlockKey";
static NSString *kOverMaxLengthBlockKey = @"kOverMaxLengthBlockKey";
- (void)limitTextLength:(int)length editEndBlock:(EditEndBlock)editEndBlock overMaxLengthBlock:(OverMaxLengthBlock)overMaxLengthBlock {
    //增加成员变量
    objc_setAssociatedObject(self, (__bridge const void *)(kTextMaxLengthKey), [NSNumber numberWithInt:length], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (editEndBlock) {
        objc_setAssociatedObject(self, (__bridge const void *)(kEditEndBlockKey), editEndBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }

    if (overMaxLengthBlock) {
        objc_setAssociatedObject(self, (__bridge const void *)(kOverMaxLengthBlockKey), overMaxLengthBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }

    [self addTarget:self action:@selector(textFieldTextLengthLimit:) forControlEvents:UIControlEventEditingChanged];
    [self addTarget:self action:@selector(textFieldDidEndEdit:) forControlEvents:UIControlEventEditingDidEnd];
}

- (void)textFieldDidEndEdit:(UITextField *)textField {
    EditEndBlock block = objc_getAssociatedObject(self, (__bridge const void *)(kEditEndBlockKey));
    if (block) {
        block(textField.text);
    }
}

- (void)callBackOverLimitBlock{
    OverMaxLengthBlock block = objc_getAssociatedObject(self, (__bridge const void *)(kOverMaxLengthBlockKey));
    if (block) {
        block();
    }
}

- (void)textFieldTextLengthLimit:(id)sender
{
    NSNumber *lengthNumber = objc_getAssociatedObject(self, (__bridge const void *)(kTextMaxLengthKey));
    int length = [lengthNumber intValue];
    NSString *inputText = [self text];

    UITextRange *selectedRange = [self markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [self positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    NSString * selectedtext = [self textInRange:selectedRange];
    NSString *preStr = [inputText substringToIndex:[inputText length]-[selectedtext length]];
    //判断如果有高亮且减去高亮的字符串大于最大的字符长度则截断或没有高亮当前字符串已经大于最大长度。
    if ([preStr length] > length) {
        NSString *strNew = [NSString stringWithString:inputText];
        [self setText:[strNew substringToIndex:length]];
        [self callBackOverLimitBlock];
        return;
    }
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        return;
    }
}



@end
