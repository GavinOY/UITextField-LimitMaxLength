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
    int maxLength = [lengthNumber intValue];
    NSString *inputText = [self text];

    UITextRange *selectedRange = [self markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [self positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    NSString * selectedtext = [self textInRange:selectedRange];
    NSString *preTextFiledStr = [inputText substringToIndex:[inputText length]-[selectedtext length]];
    //判断如果有高亮且减去高亮的字符串大于最大的字符长度则截断或没有高亮当前字符串已经大于最大长度。
    if ([self getInputTextLength:preTextFiledStr] > maxLength) {
        NSString *subText= [self clipOverMaxLengthStr:preTextFiledStr maxLength:maxLength];
        [self setText:subText];
        [self callBackOverLimitBlock];
    }
}

-(NSString*)clipOverMaxLengthStr:(NSString*)text maxLength:(NSInteger)maxLen{
    if ([self getInputTextLength:text] <= maxLen) {
        return text;
    }

    NSInteger needLength = maxLen;
    //用i记录需要截取的下标
    NSInteger i = 0;
    for (; needLength > 0; i++) {
        int character = [text characterAtIndex:i];
        if( character >= 0x4e00 && character <= 0x9fff) {
            needLength -= 2;
        }
        else {
            needLength--;
        }
    }
    //出现了最后一个字是中文的情况，这时needLength为-1
    if (needLength < 0) {
        i --;
    }
    NSString *subStr = [text substringToIndex:i];
    return subStr;
}

- (NSInteger)getInputTextLength:(NSString*)text{
    if ([text length] <1) {
        return 0;
    }
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data= [text dataUsingEncoding:encoding];
    NSInteger length=[data length];
    return length;
}


@end
