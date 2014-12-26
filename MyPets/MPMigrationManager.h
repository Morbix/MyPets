//
//  MPMigrationManager.h
//  MyPets
//
//  Created by Henrique Morbin on 24/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MPMigrationStatusProgress,
    MPMigrationStatusCanceled,
    MPMigrationStatusDone
} MPMigrationStatus;

@interface MPMigrationManager : NSObject

- (void)startMigration;

@end
