# TYPasterView
这是一个贴纸控件的实现，简单易用。

- 支持拖拽，旋转，缩放手势。
- 支持旋转，缩放，删除按钮。
- 多贴纸控件管理。



## 使用

``` objective-c
UIImage *image = [UIImage imageNamed:@"imageName"];
TYPasterView * view = [[TYPasterManager sharedInstance] pasterWithImage:image];
view.frame = (CGRect){CGPointZero,CGSizeMake(150, 100)};
view.center = CGPointMake(200, 200);
[self.view addSubview:view];
```



## 效果

请运行TYPasterDemo查看运行效果。