# UITextFiled-LimitLength
# 限制输入框长度的UITextFiled
# 开始使用，限制N长度

[textFiled limitTextLength:20
              editEndBlock:^(NSString *text) {
                    NSLog(@"%@",text);
             } 
       overMaxLengthBlock:^{
            NSLog(@"overLimitBlock");
}];
