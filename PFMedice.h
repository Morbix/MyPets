//
//  PFMedice.h
//  MyPets
//
//  Created by Henrique Morbin on 27/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Parse/Parse.h>

@class PFAnimal;

@interface PFMedice : PFObject <PFSubclassing>

@property (retain) PFUser *owner;
@property (retain) NSString *identifier;
@property (retain) NSDate *dateAndTime;
@property (retain) NSString *dose;
@property (retain) NSString *mediceId;
@property (assign) int reminder;
@property (retain) NSString *name;
@property (retain) NSString *notes;
@property (assign) float weight;
@property (retain) NSString *type;
@property (retain) PFAnimal *animal;

+ (NSString *)parseClassName;

@end
