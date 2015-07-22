//
//  NSLayoutConstraint+Util.h
//  iPenYou
//
//  Created by trgoofi on 14-7-28.
//  Copyright (c) 2014年 vbuy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Util)
+ (NSArray *)constraintsWithVisualFormat:(NSString *)format
                                 options:(NSLayoutFormatOptions)opts
                                 metrics:(NSDictionary *)metrics
                                   views:(NSDictionary *)views
                                  toView:(UIView *)view;

+ (id)constraintWithItem:(id)view1
               attribute:(NSLayoutAttribute)attr1
               relatedBy:(NSLayoutRelation)relation
                  toItem:(id)view2
               attribute:(NSLayoutAttribute)attr2
              multiplier:(CGFloat)multiplier
                constant:(CGFloat)c
                  toView:(UIView *)view;

@end
