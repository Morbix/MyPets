//
//  MXGoogleAnalytics.m
//  PickUpSticks
//
//  Created by Henrique Morbin on 26/07/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MXGoogleAnalytics.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@implementation MXGoogleAnalytics

+ (void)ga_trackScreen:(NSString *)screen
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:screen];
    
    // Previous V3 SDK versions
    // [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    // May return nil if a tracker has not already been initialized with a property
    // ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category     // Event category (required)
                                                          action:action  // Event action (required)
                                                           label:label          // Event label
                                                           value:value] build]];    // Event value
}

+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action label:(NSString *)label
{
    [MXGoogleAnalytics ga_trackEventWith:category action:action label:label value:nil];
}

+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action
{
    [MXGoogleAnalytics ga_trackEventWith:category action:action label:@"" value:nil];
}
@end
