//
//  MPTargets.m
//  MyPets
//
//  Created by HP Developer on 11/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPTargets.h" //FREE

#define kTargetAppID @"553815375"
#define kTargetAds NO
#define kTargetNumberOfSections 4
#define kTargetAnalyticsID @"UA-46756135-1"
#define kTargetChannel @"App_Free"

//Ok - appirater
//Ok - ads
//Ok - analytics
//Ok - channer parse
//Ok - numero de sections nas configuracoes
//Ok - ReviewID nas configuracoes

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
