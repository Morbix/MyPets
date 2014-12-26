//
//  PetShop.h
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Banho;

@interface PetShop : NSManagedObject

@property (nonatomic, retain) NSString * cIdentifier;
@property (nonatomic, retain) NSString * cEmail;
@property (nonatomic, retain) NSString * cEndereco;
@property (nonatomic, retain) NSString * cNome;
@property (nonatomic, retain) NSString * cObs;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) NSString * cTelefone;
@property (nonatomic, retain) NSSet *cArrayBanhos;
@end

@interface PetShop (CoreDataGeneratedAccessors)

- (void)addCArrayBanhosObject:(Banho *)value;
- (void)removeCArrayBanhosObject:(Banho *)value;
- (void)addCArrayBanhos:(NSSet *)values;
- (void)removeCArrayBanhos:(NSSet *)values;

@end
