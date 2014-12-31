//
//  MPCoreDataModelProtocol.h
//  MyPets
//
//  Created by Henrique Morbin on 30/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPCoreDataModelProtocol <NSObject>

@property (nonatomic, retain) NSString * cIdentifier;
@property (nonatomic, retain) NSDate * updatedAt;

@end
