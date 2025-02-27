//
//  Banho.h
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Animal, PetShop;

@interface Banho : NSManagedObject

@property (nonatomic, retain) NSDate * cData;
@property (nonatomic, retain) NSDate * cHorario;
@property (nonatomic, retain) NSString * cID;
@property (nonatomic, retain) NSString * cLembrete;
@property (nonatomic, retain) NSString * cObs;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) NSNumber * cPeso;
@property (nonatomic, retain) Animal *cAnimal;
@property (nonatomic, retain) PetShop *cPetShop;

@end
