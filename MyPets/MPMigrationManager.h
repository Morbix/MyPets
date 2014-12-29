//
//  MPMigrationManager.h
//  MyPets
//
//  Created by Henrique Morbin on 24/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MPMigrationStatusNone, //Before start
    MPMigrationStatusInProgress, //During the migration
    MPMigrationStatusCancelled, //Canceled (maybe because lack of internet connection)
    MPMigrationStatusStopped, //Finished wit issues
    MPMigrationStatusDone, //Finished without issues
} MPMigrationStatus;

@protocol MPMigrationDelegate;

@interface MPMigrationManager : NSObject

@property (nonatomic, strong) id<MPMigrationDelegate> delegate;
@property (nonatomic, assign) MPMigrationStatus migrationStatus;

- (void)startMigration;

@end

@protocol MPMigrationDelegate <NSObject>

@optional
- (void)migration:(MPMigrationManager *)manager didChangeStatus:(MPMigrationStatus)status;

@end
