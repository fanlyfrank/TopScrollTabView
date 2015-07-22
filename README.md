# TopScrollTabView

A tabview like neteasy news app, 懂球帝 app. you can scroll top tabs and tap tab item to switch the content at the bottom, or you can just swip the bottom content view to switch content.

# Installation

There are tow ways to use TopScrollTabView in your project:
1, using Cocoapods;
2, copying TSTView.h,TSTView.m,NSLayoutConstraint+Util.h,NSLayoutConstraint+Util.m to your project.

# Installation with CocoaPods 

pod 'TopScrollTabView', '1.0'

# Usage

You can use this view just like this:

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
    

