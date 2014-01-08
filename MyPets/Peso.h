//
//  Peso.h
//  MyPets
//
//  Created by HP Developer on 08/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Animal;

@interface Peso : NSManagedObject

@property (nonatomic, retain) NSString * cID;
@property (nonatomic, retain) NSNumber * cPeso;
@property (nonatomic, retain) NSDate * cData;
@property (nonatomic, retain) NSString * cObs;
@property (nonatomic, retain) Animal *cAnimal;

@end
