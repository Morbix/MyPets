//
//  MPAnimations.h
//  MyPets
//
//  Created by HP Developer on 11/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPAnimations : NSObject

+ (void)animationPressDown:(UIView *)view;
+ (void)animationPressDown:(UIView *)view completion:(void (^)(BOOL finished))completion;
@end
