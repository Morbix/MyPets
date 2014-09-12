//
//  MXGoogleAnalytics.h
//  PickUpSticks
//
//  Created by Henrique Morbin on 26/07/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXGoogleAnalytics : NSObject

+ (void)ga_trackScreen:(NSString *)screen;
+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action label:(NSString *)label;
+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action;
@end
