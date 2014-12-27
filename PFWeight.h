//
//  PFWeight.h
//  MyPets
//
//  Created by Henrique Morbin on 27/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Parse/Parse.h>

@class PFAnimal;

@interface PFWeight : PFObject <PFSubclassing>

@property (retain) PFUser *owner;
@property (retain) NSString *identifier;
@property (retain) NSDate *dateAndTime;
@property (retain) NSString *weightId;
@property (retain) NSString *notes;
@property (assign) float weight;
@property (retain) PFAnimal *animal;

+ (NSString *)parseClassName;

@end
