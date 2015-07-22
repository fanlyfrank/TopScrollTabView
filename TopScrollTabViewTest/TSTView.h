//
//  TSTView.h
//  iPenYou
//
//  Created by fanly frank on 5/22/15.
//  Copyright (c) 2015 vbuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class TSTView;

@protocol TSTViewDataSource <NSObject>

@required
- (NSInteger)numberOfTabsInTSTView:(TSTView *)tstview;
- (NSString *)tstview:(TSTView *)tstview titleForTabAtIndex:(NSInteger)tabIndex;
- (UIView *)tstview:(TSTView *)tstview viewForSelectedTabIndex:(NSInteger)tabIndex;

@end

@protocol TSTViewDelegate <NSObject>

@optional

- (UIColor *)tabViewBackgroundColorForTSTView:(TSTView *)tstview;
- (UIColor *)highlightColorForTSTView:(TSTView *)tstview;
- (UIColor *)normalColorForTSTView:(TSTView *)tstview;
- (UIColor *)normalColorForSeparatorInTSTView:(TSTView *)tstview;

- (CGFloat)heightForTabInTSTView:(TSTView *)tstview;
- (CGFloat)heightForTabSeparatorInTSTView:(TSTView *)tstview;
- (CGFloat)heightForSelectedIndicatorInTSTView:(TSTView *)tstview;

- (UIFont *)fontForTabTitleInTSTView:(TSTView *)tstview;

- (void)tstview:(TSTView *)tstview didSelectedTabAtIndex:(NSInteger)tabIndex;

@end

@interface TSTView : UIView <UIScrollViewDelegate>

@property (assign, nonatomic) id <TSTViewDataSource> dataSource;
@property (assign, nonatomic) id <TSTViewDelegate> delegate;

- (void)registerReusableContentViewClass:(Class)contentViewClass;
- (id)dequeueReusableContentView;

- (NSString *)titleForSelectedTab;
- (NSInteger)indexForSelectedTab;

- (UIScrollView *)topTabViewInTSTView;

- (void)reloadData;

@end

