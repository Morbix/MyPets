//
//  Vacina.h
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Animal;

@interface Vacina : NSManagedObject

@property (nonatomic, retain) NSDate * cData;
@property (nonatomic, retain) NSDate * cDataVacina;
@property (nonatomic, retain) NSString * cDose;
@property (nonatomic, retain) NSString * cID;
@property (nonatomic, retain) NSString * cLembrete;
@property (nonatomic, retain) NSString * cObs;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) NSNumber * cFoto_Edited;
@property (nonatomic, retain) NSString * cPeso;
@property (nonatomic, retain) NSData * cSelo;
@property (nonatomic, retain) NSString * cVeterinario;
@property (nonatomic, retain) Animal *cAnimal;

- (UIImage *)getFoto;

@end
