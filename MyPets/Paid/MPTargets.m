//
//  MPTargets.m
//  MyPets
//
//  Created by HP Developer on 11/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPTargets.h" //PAID

#define kTargetAppID @"795757886"
#define kTargetAds NO
#define kTargetNumberOfSections 3
#define kTargetAnalyticsID @"UA-46756135-2"
#define kTargetChannel @"App_Paid"

@implementation MPTargets

+ (NSString *)targetAppID
{
    return kTargetAppID;
}

+ (BOOL)targetAds
{
    return kTargetAds;
}

+ (int)targetNumberOfSections
{
    return kTargetNumberOfSections;
}

+ (NSString *)targetAnalyticsID
{
    return kTargetAnalyticsID;
}

+ (NSString *)targetChannel
{
    return kTargetChannel;
}

@end
