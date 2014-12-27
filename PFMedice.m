//
//  PFMedice.m
//  MyPets
//
//  Created by Henrique Morbin on 27/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "PFMedice.h"

@implementation PFMedice

@dynamic owner;
@dynamic identifier;
@dynamic dateAndTime;
@dynamic dose;
@dynamic mediceId;
@dynamic reminder;
@dynamic name;
@dynamic notes;
@dynamic weight;
@dynamic type;
@dynamic animal;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Medicine";
}

@end
