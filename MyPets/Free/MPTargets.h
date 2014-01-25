//
//  MPTargets.h
//  MyPets
//
//  Created by HP Developer on 11/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MPTargets : NSObject

+ (NSString *)targetAppID;
+ (BOOL)targetAds;
+ (int)targetNumberOfSections;
+ (NSString *)targetAnalyticsID;
+ (NSString *)targetChannel;

@end
