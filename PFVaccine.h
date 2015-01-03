//
//  PFVaccine.h
//  MyPets
//
//  Created by Henrique Morbin on 27/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Parse/Parse.h>

@class PFAnimal;

@interface PFVaccine : PFObject  <PFSubclassing>

@property (retain) PFUser *owner;
@property (retain) NSString *identifier;
@property (retain) NSDate *dateAndTime;
@property (retain) NSDate *dateAndTimeVaccine;
@property (retain) NSString *dose;
@property (retain) NSString *vaccineId;
@property (assign) int reminder;
@property (retain) NSString *notes;
@property (assign) NSString *weight;
@property (retain) NSString *veterinarian;
@property (retain) PFFile *photo;
@property (retain) PFAnimal *animal;

+ (NSString *)parseClassName;

@end
