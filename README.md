# tools
项目中用到的一些tools

包含网络请求、视频播放、支付、分享等类的封装及对第三方库的封装和修改

## TTUINavigationExtension 

![image](https://github.com/sun8801/tools/TT_navigation_bar.gif)

  封装了修改导航栏的操作，可以设置导航栏的颜色、背景图、透明度，不同的VC 可以设置不同的导航栏，无缝切换
  只需在` viewDidLoad`中设置 即可或在需要是设置
  支持的属性如下：
  ``` 
  /**
  设置导航栏背景色
  */
  @property (nonatomic, strong) UIColor *TT_navigationBarBackgroundColor;
  
  /**
  设置导航栏背景图
  */
  @property (nonatomic, strong) UIImage *TT_navigationBarBackgroundImage;
  
  /**
  设置导航栏背景透明度 [0 - 1]
  */
  @property (nonatomic, assign) CGFloat TT_navigationBarBackgroundAlpha;
  
  /**
  设置导航栏透明度 [0 - 1]
  */
  @property (nonatomic, assign) CGFloat TT_navigationBarAlpha;
  
  /**
  是否隐藏导航栏
  */
  @property (nonatomic, assign) BOOL TT_navigationBarHidden;
  ```
 ` ToolDemo`工程中有部分测试代码
 
