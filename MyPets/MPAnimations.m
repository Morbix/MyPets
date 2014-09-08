//
//  MPAnimations.m
//  MyPets
//
//  Created by HP Developer on 11/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPAnimations.h"

@implementation MPAnimations

+ (void)animationPressDown:(UIView *)view
{
    [UIView animateWithDuration:0.1f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         (view).transform = CGAffineTransformMakeScale(0.9f, 0.9f);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1f
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              (view).transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];
                     }];
}

+ (void)animationPressDown:(UIView *)view completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.1f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         (view).transform = CGAffineTransformMakeScale(0.9f, 0.9f);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1f
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              (view).transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                          }
                                          completion:completion];
                     }];
}
@end
