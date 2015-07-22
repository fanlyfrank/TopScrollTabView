//
//  TSTView.m
//  iPenYou
//
//  Created by fanly frank on 5/22/15.
//  Copyright (c) 2015 vbuy. All rights reserved.
//

#import "TSTView.h"
#import "NSLayoutConstraint+Util.h"

@interface TSTView ()

//subviews
@property (strong, nonatomic) UIScrollView *topTabView;
@property (strong, nonatomic) UIScrollView *contentView;
@property (strong, nonatomic) UIView *tabShadowView;
@property (strong, nonatomic) UIView *tabSeparator;

//appearance
@property (assign, nonatomic) CGFloat tabSpace;
@property (assign, nonatomic) CGFloat tabShadowHeight;
@property (assign, nonatomic) CGFloat leading;
@property (assign, nonatomic) CGFloat trailing;
@property (assign, nonatomic) CGFloat tabHeight;
@property (assign, nonatomic) CGFloat tabSeparatorHeight;

@property (strong, nonatomic) UIColor *tabHighlightColor;
@property (strong, nonatomic) UIColor *tabNormalColor;
@property (strong, nonatomic) UIColor *tabBackgroundColor;
@property (strong, nonatomic) UIColor *tabSeparatorColor;

@property (strong, nonatomic) UIFont *tabFont;

@property (strong, nonatomic) NSLayoutConstraint *tabShadowLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *tabShadowHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *tabShadowWidthConstraint;

//logic datas
@property (assign, nonatomic) NSInteger tabsCount;

@property (strong, nonatomic) NSMutableArray *reuseableContentViews;
@property (assign, nonatomic) Class reuswableContentViewClass;

@property (strong, nonatomic) UIButton *currentSelectedBtn;
@property (strong, nonatomic) NSMutableArray *tabButtons;

@property (assign, nonatomic) NSInteger currentSelectedIndex;
@property (assign, nonatomic) NSInteger currentLoadIndex;
@property (assign, nonatomic) NSInteger previousSelectedIndex;

@property (assign, nonatomic) BOOL isForwardSwip;


@end

@implementation TSTView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //init appearance
        _tabSpace = 25.f;
        _leading = 5.f;
        _trailing = 5.f;
        _tabShadowHeight = 3.f;
        _tabHeight = 30.f;
        _tabSeparatorHeight = .5f;
        
        _tabHighlightColor = [UIColor greenColor];
        _tabNormalColor = [UIColor redColor];
        _tabBackgroundColor = [UIColor clearColor];
        
        //init view
        _topTabView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, self.tabHeight)];
        _topTabView.translatesAutoresizingMaskIntoConstraints = NO;
        _topTabView.showsHorizontalScrollIndicator = NO;
        _topTabView.showsVerticalScrollIndicator = NO;
        _topTabView.autoresizingMask = UIViewAutoresizingNone;
        
        _tabSeparator = [[UIView alloc] initWithFrame:
                         CGRectMake(0, self.tabHeight - self.tabSeparatorHeight,frame.size.width, self.tabSeparatorHeight)];
        _tabSeparator.translatesAutoresizingMaskIntoConstraints = NO;
        _tabSeparator.backgroundColor = self.tabNormalColor;
        
        
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.tabHeight, frame.size.width, frame.size.height - self.tabHeight)];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.scrollEnabled = YES;
        _contentView.autoresizingMask = UIViewAutoresizingNone;
        _contentView.autoresizesSubviews = NO;
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.pagingEnabled = YES;
        _contentView.delegate = self;
        
        [self addSubview:_topTabView];
        [self addSubview:_tabSeparator];
        [self addSubview:_contentView];
        
        //init data
        _tabButtons = [[NSMutableArray alloc] initWithCapacity:5];
        _reuseableContentViews = [[NSMutableArray alloc] initWithCapacity:3];
        _previousSelectedIndex = -1;
        _currentSelectedIndex = -1;
        _currentLoadIndex = 0;
        _isForwardSwip = YES;
        
    }
    
    return self;
}

#pragma mark -- public methods

- (void)reloadData {
    
    [self updateBasicSubviewsConstraint];
    [self buildTabViews];
    
    [self layoutIfNeeded];
    
    [self buildContentViews];
    
    
    self.currentSelectedBtn = [self.tabButtons firstObject];
    [self autoScrollTopTabBySwipDirctionToPage:0];
}

- (void)registerReusableContentViewClass:(Class)contentViewClass {
    self.reuswableContentViewClass = contentViewClass;
}

- (id)dequeueReusableContentView {
    
    id contentView;
    
    if (!self.reuswableContentViewClass) {
        NSLog(@"before invoke dequeueReusableContentView, you must invoke registerReusableContentViewClass:(Class)contentViewClass first!");
        abort();
    }
    
    if (self.reuseableContentViews.count >= 3) {
        contentView = self.reuseableContentViews[self.currentLoadIndex % 3];
        
        if (![contentView isKindOfClass:self.reuswableContentViewClass]) {
            NSLog(@"content view you provide by methods tstview:viewForSelectedTabIndex:, is not a class you register by methods registerReusableContentViewClass:, pleas make sure they are stay the same!");
            abort();
        }
    }
    
    return contentView;
}

- (NSString *)titleForSelectedTab {
    return self.currentSelectedBtn.titleLabel.text;
}

- (NSInteger)indexForSelectedTab {
    return self.currentSelectedIndex;
}

#pragma mark --  scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger currentIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    
    [self autoScrollTopTabBySwipDirctionToPage:currentIndex];
    
    if (currentIndex == self.previousSelectedIndex) {
        
        return;
    }
    
    [self loadContentViewByScrollContent:currentIndex];
    
    if ([self.delegate respondsToSelector:@selector(tstview:didSelectedTabAtIndex:)]) {
        
        [self.delegate tstview:self didSelectedTabAtIndex:currentIndex];
    }
    
}

#pragma mark -- build methods

- (void)buildTabViews {
    
    if (self.dataSource) {
        
        if ([self.delegate respondsToSelector:@selector(highlightColorForTSTView:)]) {
            self.tabHighlightColor = [self.delegate highlightColorForTSTView:self];
        }
        
        if ([self.delegate respondsToSelector:@selector(normalColorForTSTView:)]) {
            self.tabNormalColor = [self.delegate normalColorForTSTView:self];
        }
        
        if ([self.delegate respondsToSelector:@selector(normalColorForSeparatorInTSTView:)]) {
            self.tabSeparatorColor = [self.delegate normalColorForSeparatorInTSTView:self];
        }
        
        if ([self.delegate respondsToSelector:@selector(heightForSelectedIndicatorInTSTView:)]) {
            self.tabShadowHeight = [self.delegate heightForSelectedIndicatorInTSTView:self];
        }
        
        [self buildTabButtons];
        [self addConstraintToTabButtons];
        
        [self buildTabShadowView];
        [self addConstraintToTabShadowWihtAnchor:[self.tabButtons lastObject]];
        
        self.tabSeparator.backgroundColor = self.tabSeparatorColor;
        
    }
}

- (void)buildContentViews {
    
    self.contentView.contentSize = CGSizeMake(self.contentView.frame.size.width * self.tabsCount, self.contentView.frame.size.height);
    
    if (self.dataSource && self.tabsCount > 0) {
        
        UIView *contentAtIndex0 = [self.dataSource tstview:self viewForSelectedTabIndex:0];
        contentAtIndex0.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        
        [self.contentView addSubview:contentAtIndex0];
        [self.reuseableContentViews addObject:contentAtIndex0];
    }
    
    if (self.dataSource && self.tabsCount > 1) {
        UIView *contentAtIndex1 = [self.dataSource tstview:self viewForSelectedTabIndex:1];
        contentAtIndex1.frame = CGRectMake(self.frame.size.width, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        
        [self.contentView addSubview:contentAtIndex1];
        [self.reuseableContentViews addObject:contentAtIndex1];
    }
}

- (void)buildTabShadowView {
    
    _tabShadowView = [[UIView alloc] init];
    
    self.tabShadowView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tabShadowView.backgroundColor = self.tabHighlightColor;
    
    [self.topTabView  addSubview:self.tabShadowView];
}

- (void)buildTabButtons {
    
    self.tabsCount = [self.dataSource numberOfTabsInTSTView:self];
    
    UIFont *titleFont;
    if ([self.delegate respondsToSelector:@selector(fontForTabTitleInTSTView:)]) {
        titleFont = [self.delegate fontForTabTitleInTSTView:self];
    }
    
    for (NSInteger i = 0; i < self.tabsCount; i ++) {
        
        NSString *currentTabTitle = [self.dataSource tstview:self titleForTabAtIndex:i];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        if (titleFont) {
            btn.titleLabel.font = titleFont;
        }
        
        btn.tag = i;
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn setTitle:currentTabTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor greenColor] forState:UIControlStateDisabled];
        
        [btn addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.tabButtons addObject:btn];
        [self.topTabView addSubview:btn];
    }
}

#pragma mark -- logic methods

- (void)loadContentViewByTapTab:(NSInteger)index {

    if (index + 1 <= self.tabsCount - 1) {
        if ([self hasNoContentViewAtIndex:index + 1]) {
            self.currentLoadIndex = index + 1;
            [self loadContentViewByIndex:index + 1];
        }
    }
    
    if (index - 1 >= 0){
        if ([self hasNoContentViewAtIndex:index - 1]) {
            self.currentLoadIndex = index - 1;
            [self loadContentViewByIndex:index - 1];
        }
    }
    
    if ([self hasNoContentViewAtIndex:index]) {
        self.currentLoadIndex = index;
        [self loadContentViewByIndex:index];
    }
    
}

- (void)loadContentViewByScrollContent:(NSInteger)index {
    
    if (self.isForwardSwip && index + 1 <= self.tabsCount - 1) {
        
        if ([self hasNoContentViewAtIndex:index + 1]) {
            self.currentLoadIndex =  index + 1;
        }
    
    } else if (!self.isForwardSwip && index - 1 >= 0) {
        
        if ([self hasNoContentViewAtIndex:index - 1]) {
            self.currentLoadIndex = index - 1;
        }
    
    } else {
        
        return;
    }
    
    [self loadContentViewByIndex:self.currentLoadIndex];
}

- (void)loadContentViewByIndex:(NSInteger)index {
    
    if (self.dataSource) {
        UIView *contentView = [self.dataSource tstview:self
                               viewForSelectedTabIndex:index];
        contentView.frame = CGRectMake(index * self.contentView.frame.size.width, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        
        [self holdViewIfNecessary:contentView];
    }
}

- (BOOL)hasNoContentViewAtIndex:(NSInteger)index {
    
    BOOL result = YES;
    
    for (UIView *subview in self.contentView.subviews) {
        if (subview.frame.origin.x == self.contentView.frame.size.width * index) {
            result = NO;
        }
    }
    
    return result;
}

- (void)holdViewIfNecessary:(UIView *)view {
    
    if (![self.reuseableContentViews containsObject:view]) {
        [self.reuseableContentViews addObject:view];
    }
    
    if (![[self.contentView subviews] containsObject:view]) {
        [self.contentView addSubview:view];
    }
}

- (void)autoScrollTopTabBySwipDirctionToPage:(NSInteger)page {

    self.previousSelectedIndex = self.currentSelectedIndex;
    self.currentSelectedIndex = page;
    
    self.currentSelectedBtn = self.tabButtons[page];
    
    if (self.previousSelectedIndex < page) {
        self.isForwardSwip = YES;
    }
    else if (self.previousSelectedIndex > page) {
        self.isForwardSwip = NO;
    }
    
    CGFloat tag;
    CGFloat btnX;
    CGFloat subtrace;
    CGFloat spare;
    CGFloat tabsOffsetX = self.topTabView.contentOffset.x;
    
    CGFloat tabsFrameWidth = self.topTabView.frame.size.width;
    CGFloat tabsContentWidth = self.topTabView.contentSize.width;
    
    CGFloat frameWidth = self.frame.size.width;
    
    tag = tabsOffsetX + frameWidth / 2 ;
    btnX = self.currentSelectedBtn.center.x;
    subtrace = self.isForwardSwip ? btnX - tag : tag - btnX;
    
    if (subtrace >= 0) {
        
        //calculate tab scorll content offset
        spare = self.isForwardSwip ? tabsContentWidth - (tabsOffsetX + tabsFrameWidth) : tabsOffsetX;
        
        spare = spare < 0 ? 0 : spare;
        
        CGFloat moveX = spare > subtrace ? subtrace : spare;
        
        moveX = self.isForwardSwip ? tabsOffsetX + moveX : tabsOffsetX - moveX;
        
        //animate change
        [UIView animateWithDuration:0.25f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             self.topTabView.contentOffset = CGPointMake(moveX, 0);
                             
                         } completion:nil];
        
    }
    
    //calculate tab title color and separtor width and color
    for (UIButton *btn in self.tabButtons) {
        
        if (btn.tag == self.currentSelectedBtn.tag) {
            btn.userInteractionEnabled = NO;
            [btn setTitleColor:self.tabHighlightColor forState:UIControlStateNormal];
        } else {
            btn.userInteractionEnabled = YES;
            [btn setTitleColor:self.tabNormalColor forState:UIControlStateNormal];
        }
        
    }
    
    self.tabShadowLeftConstraint.constant = self.currentSelectedBtn.frame.origin.x;
    self.tabShadowWidthConstraint.constant = self.currentSelectedBtn.frame.size.width;
    
    [UIView animateWithDuration:.25 animations:^{
        [self layoutIfNeeded];
    }];
    
}

#pragma mark -- update constraint methods
- (void)updateBasicSubviewsConstraint {
    
    if ([self.delegate respondsToSelector:@selector(tabViewBackgroundColorForTSTView:)]) {
        self.topTabView.backgroundColor = [self.delegate tabViewBackgroundColorForTSTView:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(heightForTabInTSTView:)]) {
        self.tabHeight = [self.delegate heightForTabInTSTView:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(heightForTabSeparatorInTSTView:)]) {
        self.tabSeparatorHeight = [self.delegate heightForTabSeparatorInTSTView:self];
    }
    
    //top tab view to self
    [NSLayoutConstraint constraintWithItem:self.topTabView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeTop
                                multiplier:1
                                  constant:0
                                    toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.topTabView
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1
                                  constant:0
                                    toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.topTabView
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1
                                  constant:0
                                    toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.topTabView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topTabView
                                 attribute:NSLayoutAttributeHeight
                                multiplier:0
                                  constant:self.tabHeight
                                    toView:self.topTabView];
    
    //separator to top tab
    [NSLayoutConstraint constraintWithItem:self.tabSeparator
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topTabView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:0
                                    toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.tabSeparator
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1
                                  constant:0
                                    toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.tabSeparator
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1
                                  constant:0
                                    toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.tabSeparator
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.tabSeparator
                                 attribute:NSLayoutAttributeHeight
                                multiplier:0
                                  constant:self.tabSeparatorHeight
                                    toView:self.tabSeparator];
    
    
    //content view to top tab
    [NSLayoutConstraint constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.tabSeparator
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:0
                                    toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1
                                  constant:0
                                    toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1
                                  constant:0
                                    toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:0
                                    toView:self];
}

- (void)addConstraintToTabButtons
{
    UIButton *firstButton = [self.tabButtons firstObject];
    UIButton *lastButton = [self.tabButtons lastObject];
    
    [NSLayoutConstraint constraintWithItem:self.topTabView
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:lastButton
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1
                                  constant:self.trailing * 2
                                    toView:self.topTabView];
    
    [NSLayoutConstraint constraintWithItem:firstButton
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topTabView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1
                                  constant:self.leading * 2
                                    toView:self.topTabView];
    
    [NSLayoutConstraint constraintWithItem:lastButton
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topTabView
                                 attribute:NSLayoutAttributeHeight
                                multiplier:1
                                  constant:0
                                    toView:self.topTabView];
    
    [NSLayoutConstraint constraintWithItem:lastButton
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topTabView
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1
                                  constant:0
                                    toView:self.topTabView];
    
    for (NSInteger i = [self.tabButtons count] - 1; i > 0; --i) {
        
        [NSLayoutConstraint constraintWithItem:self.tabButtons[i]
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.tabButtons[i - 1]
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:1
                                      constant:0
                                        toView:self.topTabView];
        
        [NSLayoutConstraint constraintWithItem:self.tabButtons[i]
                                     attribute:NSLayoutAttributeBaseline
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.tabButtons[i - 1]
                                     attribute:NSLayoutAttributeBaseline
                                    multiplier:1
                                      constant:0
                                        toView:self.topTabView];
        
        [NSLayoutConstraint constraintWithItem:self.tabButtons[i]
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.tabButtons[i - 1]
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1
                                      constant:self.tabSpace
                                        toView:self.topTabView];
    }
}

- (void)addConstraintToTabShadowWihtAnchor:(UIView *)anchor {
    
    self.tabShadowLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.tabShadowView
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topTabView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1
                                  constant:self.leading
                                    toView:self.topTabView];
    
    [NSLayoutConstraint constraintWithItem:self.tabShadowView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:anchor
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:0
                                    toView:self.topTabView];
    
    self.tabShadowHeightConstraint =
    [NSLayoutConstraint constraintWithItem:self.tabShadowView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:anchor
                                 attribute:NSLayoutAttributeHeight
                                multiplier:0
                                  constant:self.tabShadowHeight
                                    toView:self.topTabView];
    
    self.tabShadowWidthConstraint =
    [NSLayoutConstraint constraintWithItem:self.tabShadowView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:anchor
                                 attribute:NSLayoutAttributeWidth
                                multiplier:0
                                  constant:0
                                    toView:self.topTabView];
}

#pragma mark -- button aciton
- (void)selectTab:(UIButton *)selectedBtn {
    
    if (!selectedBtn) {
        return;
    }
    
    NSInteger currentIndex = selectedBtn.tag;
    self.currentSelectedBtn = selectedBtn;
    
    [self autoScrollTopTabBySwipDirctionToPage:currentIndex];
    
    [self loadContentViewByTapTab:currentIndex];
    
    self.contentView.contentOffset = CGPointMake(self.contentView.frame.size.width * currentIndex, 0);

}


- (UIScrollView *)topTabViewInTSTView
{
    return self.topTabView;
}

@end
