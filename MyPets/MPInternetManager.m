//
//  MPInternetManager.m
//  MyPets
//
//  Created by Henrique Morbin on 26/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPInternetManager.h"

#import "Reachability.h" //pod 'Reachability' by https://github.com/tonymillion/Reachability

@interface MPInternetManager()

@property (nonatomic, strong) Reachability *reach;

@end

@implementation MPInternetManager

+ (instancetype)shared
{
    static MPInternetManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPInternetManager new];
        
        manager.reach = [Reachability reachabilityWithHostname:@"www.google.com"];

        [[NSNotificationCenter defaultCenter] addObserver:manager
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        [manager.reach startNotifier];
    });
    
    return manager;
}

- (BOOL)hasInternetConnection
{
    return [self.reach isReachable];
}

- (BOOL)hasInternetConnectionViaWifi
{
    return [self.reach isReachableViaWiFi];
}

- (void)reachabilityChanged:(NSNotification*)notification
{
    if (MX_DESENV_MODE) {
        NSLog(@"Reachability changed to %d (NSNotification)", self.reach.reachabilityFlags);
    }
}
@end
