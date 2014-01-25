//
//  MPDropboxNotification.h
//  MyPets
//
//  Created by HP Developer on 25/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MTPSNotificationSyncUpdate @"br.com.alltouch.mypets.notification.syncUpdate"

@interface MPDropboxNotification : NSObject

@property (nonatomic, assign) int queue;
@property (nonatomic, strong) NSDate *lastSyncingNotification;

+ (id)shared;

@end
