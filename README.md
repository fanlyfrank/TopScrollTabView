# TopScrollTabView

A tabview like neteasy news app(网易新闻), 懂球帝 app. you can scroll top tabs and tap tab item to switch the content at the bottom, or you can just swip the bottom content view to switch content.

类似网易新闻，懂球帝app的平铺导航控件。顶部导航栏可滑动，可点选切换栏目。也可以在内容视图里直接通过左右滑动手势，切换栏目。

# Installation

There are tow ways to use TopScrollTabView in your project:
1, using CocoaPods;
2, copying TSTView.h,TSTView.m,NSLayoutConstraint+Util.h,NSLayoutConstraint+Util.m to your project.

通过两种方式进行集成：
1，通过cocoapods；
2，直接复制如下四个文件到项目中：TSTView.h,TSTView.m,NSLayoutConstraint+Util.h,NSLayoutConstraint+Util.m

# Installation with CocoaPods 

pod 'TopScrollTabView', '1.0'

通过cocopads集成，只需要在Podfile中加入如下代码：

pod 'TopScrollTabView', '1.0'

# Usage

You can use this view just like this:

使用方法可参照如下代码：

```Objective-c
#import "TSTView.h"

- (void)viewDidLoad {
    
    [super viewDidLoad];
    tstview = [[TSTView alloc] init];

    tstview.dataSource = self;
    tstview.delegate = self;

    //this is important for content view reuse
    [tstview registerReusableContentViewClass:[UIView class]];
    
    [self.view addSubview:tstview];
    
    [tstview reloadData];
}
    
```

# Appearance

You can implement TSTView delegate method to define TSTView's appearance

通过如下delegate方法可以设置TSTView的外观以满足您的个性化需求：

```Objective-c

- (UIColor *)tabViewBackgroundColorForTSTView:(TSTView *)tstview;
- (UIColor *)highlightColorForTSTView:(TSTView *)tstview;
- (UIColor *)normalColorForTSTView:(TSTView *)tstview;
- (UIColor *)normalColorForSeparatorInTSTView:(TSTView *)tstview;

- (CGFloat)heightForTabInTSTView:(TSTView *)tstview;
- (CGFloat)heightForTabSeparatorInTSTView:(TSTView *)tstview;
- (CGFloat)heightForSelectedIndicatorInTSTView:(TSTView *)tstview;

- (UIFont *)fontForTabTitleInTSTView:(TSTView *)tstview;
```

