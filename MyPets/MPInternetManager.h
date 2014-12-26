//
//  MPInternetManager.h
//  MyPets
//
//  Created by Henrique Morbin on 26/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPInternetManager : NSObject

+ (instancetype)shared;
- (BOOL)hasInternetConnection;
- (BOOL)hasInternetConnectionViaWifi;
@end
