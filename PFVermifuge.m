//
//  PFVermifuge.m
//  MyPets
//
//  Created by Henrique Morbin on 28/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "PFVermifuge.h"

@implementation PFVermifuge

@dynamic owner;
@dynamic identifier;
@dynamic dateAndTime;
@dynamic dateAndTimeVaccine;
@dynamic dose;
@dynamic vaccineId;
@dynamic reminder;
@dynamic notes;
@dynamic weight;
@dynamic photo;
@dynamic animal;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Vermifuge";
}

@end
