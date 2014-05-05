//
//  MPGoogle.m
//  MyPets
//
//  Created by HP Developer on 03/05/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPGoogle.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
@implementation MPGoogle

+ (id)shared
{
    static MPGoogle *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPGoogle new];
    });
    return manager;
}

- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
}

- (void)sendTelaWithName:(NSString *)screen
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:screen];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}
@end
