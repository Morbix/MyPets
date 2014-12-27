//
//  PFVaccine.m
//  MyPets
//
//  Created by Henrique Morbin on 27/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "PFVaccine.h"

@implementation PFVaccine

@dynamic owner;
@dynamic identifier;
@dynamic dateAndTime;
@dynamic dateAndTimeVaccine;
@dynamic dose;
@dynamic vaccineId;
@dynamic reminder;
@dynamic notes;
@dynamic weight;
@dynamic veterinarian;
@dynamic photo;
@dynamic animal;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Vaccine";
}

@end
