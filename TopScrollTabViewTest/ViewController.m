//
//  ViewController.m
//  TopScrollTabViewTest
//
//  Created by mac on 22/7/15.
//  Copyright (c) 2015 fanly. All rights reserved.
//

#import "ViewController.h"
#import "TSTView.h"
#import "UIColor+Util.h"

@interface ViewController () <TSTViewDataSource, TSTViewDelegate>

@property (strong, nonatomic) TSTView *tstView;

@property (strong, nonatomic) NSDictionary *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //
    _datas = @{@"yellow" : [UIColor yellowColor],
               @"red" : [UIColor redColor],
               @"blue" : [UIColor blueColor],
               @"orange" : [UIColor orangeColor],
               @"magenta" : [UIColor magentaColor],
               @"brown" : [UIColor brownColor],
               @"cyan" : [UIColor cyanColor]};
    
    _tstView = [[TSTView alloc] initWithFrame:self.view.frame];
    
    self.tstView.delegate = self;
    self.tstView.dataSource = self;
    
    [self.tstView registerReusableContentViewClass:[UIView class]];
    
    [self.view addSubview:self.tstView];
    [self.tstView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -- TSTView datasource metods
- (NSInteger)numberOfTabsInTSTView:(TSTView *)tstview {
    return [self.datas allKeys].count;
}

- (NSString *)tstview:(TSTView *)tstview titleForTabAtIndex:(NSInteger)tabIndex {
    return [self.datas allKeys][tabIndex];
}

- (UIView *)tstview:(TSTView *)tstview viewForSelectedTabIndex:(NSInteger)tabIndex {
    
    UIView *content = [tstview dequeueReusableContentView];
    
    if (!content) {
        content = [[UIView alloc] init];
    }
    
    NSString *key = [self.datas allKeys][tabIndex];
    content.backgroundColor = [self.datas objectForKey:key];
    
    return content;

}

#pragma mark -- TSTView delegate
- (CGFloat)heightForTabInTSTView:(TSTView *)tstview {
    return 64;
}

- (CGFloat)heightForSelectedIndicatorInTSTView:(TSTView *)tstview {
    return 6;
}

- (CGFloat)heightForTabSeparatorInTSTView:(TSTView *)tstview {
    return 1;
}

- (UIFont *)fontForTabTitleInTSTView:(TSTView *)tstview {
    return [UIFont systemFontOfSize:20];
}

- (UIColor *)highlightColorForTSTView:(TSTView *)tstview {
    return [UIColor colorWithHex:0x00C9BE];
}

- (UIColor *)normalColorForTSTView:(TSTView *)tstview {
    return [UIColor colorWithHex:0x808080];
}

- (UIColor *)tabViewBackgroundColorForTSTView:(TSTView *)tstview {
    return [UIColor colorWithHex:0x262626];
}


@end
