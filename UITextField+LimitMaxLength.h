//
//  UITextField+LimitMaxLength.h
//
//  Created by oyzhx on 16/7/21.
//  Copyright © 2016年 oyzhx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EditEndBlock)(NSString *text);
typedef void(^OverMaxLengthBlock)(void);

@interface UITextField (LimitMaxLength)
/**
*  设置输入的最大长度，这里考虑了中英文的情况
*
*  @param length         输入的长度
*  @param editEndBlock   退出编辑的回调
*  @param overLimitBlock 超过最大长度的回调
*/
- (void)limitTextLength:(int)length editEndBlock:(EditEndBlock)editEndBlock overMaxLengthBlock:(OverMaxLengthBlock)overLimitBlock;

@end
