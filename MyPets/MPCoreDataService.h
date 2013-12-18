//
//  MPCoreDataService.h
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#define MTPSNotificationPets @"br.com.alltouch.mypets.notification.pets"
#define MTPSNotificationPetsVacinas @"br.com.alltouch.mypets.notification.vacinas"

#import <Foundation/Foundation.h>
#import "Animal.h"
#import "Vacina.h"

@interface MPCoreDataService : NSObject

@property (nonatomic, strong) NSMutableArray *arrayPets;
@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) Animal *animalSelected;
@property (nonatomic, strong) Vacina *vacinaSelected;

+ (id)shared;
+ (void)saveContext;
- (void)loadAllPets;

#pragma mark - Animal
- (Animal *)newAnimal;
- (void)deleteAnimalSelected;

#pragma mark - Vacinas
- (Vacina *)newVacinaToAnimal:(Animal *)animal;

@end
