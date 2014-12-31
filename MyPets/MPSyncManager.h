//
//  MPSyncManager.h
//  MyPets
//
//  Created by Henrique Morbin on 30/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    MPSyncStatusNone, //Before start
    MPSyncStatusInProgress, //During the migration
    MPSyncStatusCancelled, //Canceled (maybe because lack of internet connection)
    MPSyncStatusStopped, //Finished wit issues
    MPSyncStatusDone, //Finished without issues
} MPSyncStatus;

@protocol MPSyncDelegate;

@interface MPSyncManager : NSObject

@property (nonatomic, strong) id<MPSyncDelegate> delegate;
@property (nonatomic, assign) MPSyncStatus syncronizationStatus;

+ (instancetype)shared;
- (void)startSyncronization;

@end

@protocol MPSyncDelegate <NSObject>

@optional
- (void)sync:(MPSyncManager *)manager didChangeStatus:(MPSyncStatus)status;

@end
