//
//  NSLayoutConstraint+Util.m
//  iPenYou
//
//  Created by trgoofi on 14-7-28.
//  Copyright (c) 2014年 vbuy. All rights reserved.
//

#import "NSLayoutConstraint+Util.h"

@implementation NSLayoutConstraint (Util)

+ (NSArray *)constraintsWithVisualFormat:(NSString *)format
                                 options:(NSLayoutFormatOptions)opts
                                 metrics:(NSDictionary *)metrics
                                   views:(NSDictionary *)views
                                  toView:(UIView *)view
{
    NSArray *constraints =[self constraintsWithVisualFormat:format options:opts metrics:metrics views:views];
    [view addConstraints:constraints];
    return constraints;
}

+ (id)constraintWithItem:(id)view1
               attribute:(NSLayoutAttribute)attr1
               relatedBy:(NSLayoutRelation)relation
                  toItem:(id)view2
               attribute:(NSLayoutAttribute)attr2
              multiplier:(CGFloat)multiplier
                constant:(CGFloat)c
                  toView:(UIView *)view
{
    id constranit = [self constraintWithItem:view1
                                   attribute:attr1
                                   relatedBy:relation
                                      toItem:view2
                                   attribute:attr2
                                  multiplier:multiplier
                                    constant:c];
    [view addConstraint:constranit];
    return constranit;
}
@end
