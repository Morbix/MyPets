//
//  Sync.h
//  MyPets
//
//  Created by Henrique Morbin on 02/01/15.
//  Copyright (c) 2015 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Sync : NSManagedObject

@property (nonatomic, retain) NSDate * classAnimal;
@property (nonatomic, retain) NSDate * classBath;
@property (nonatomic, retain) NSDate * classAppointment;
@property (nonatomic, retain) NSDate * classMedicine;
@property (nonatomic, retain) NSDate * classWeight;
@property (nonatomic, retain) NSDate * classVaccine;
@property (nonatomic, retain) NSDate * classVermifuge;

- (void)initEmptyDates;

@end
