# UITextFiled-LimitLength
# 限制输入框长度的UITextFiled
  设置限制N长度

例子
[textFiled limitTextLength:20
              editEndBlock:^(NSString *text) {
                    NSLog(@"%@",text);
             } 
       overMaxLengthBlock:^{
            NSLog(@"overLimitBlock");
}];
