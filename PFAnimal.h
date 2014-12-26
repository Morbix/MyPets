 //
//  PFAnimal.h
//  MyPets
//
//  Created by Henrique Morbin on 26/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFAnimal : PFObject <PFSubclassing>

@property (retain) PFUser *owner;
@property (retain) NSString *identifier;
@property (retain) NSDate *birthday;
@property (retain) NSString *specie;
@property (retain) PFFile *photo;
@property (retain) NSString *animalId;
@property (retain) NSString *name;
@property (retain) NSString *notes;
@property (retain) NSString *breed;
@property (retain) NSString *sex;


+ (NSString *)parseClassName;

@end
