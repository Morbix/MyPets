//
//  RageIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "MyPetsIAPHelper.h"

@implementation MyPetsIAPHelper

+ (MyPetsIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static MyPetsIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"br.com.morbix.mypets.plan_1month",
                                      @"br.com.morbix.mypets.plan_3month",
                                      @"br.com.morbix.mypets.plan_6month",
                                      @"br.com.morbix.mypets.plan_12month",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (BOOL)isPremium
{
    return ([self daysRemainingOnSubscription] > 0);
}
@end
