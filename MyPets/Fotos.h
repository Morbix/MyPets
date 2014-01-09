//
//  Fotos.h
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Animal;

@interface Fotos : NSManagedObject

@property (nonatomic, retain) NSDate * cData;
@property (nonatomic, retain) NSData * cFoto;
@property (nonatomic, retain) NSString * cIDParse;
@property (nonatomic, retain) NSString * cTags;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) Animal *cAnimal;

@end
