//
//  PFAnimal.m
//  MyPets
//
//  Created by Henrique Morbin on 26/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "PFAnimal.h"

#import <Parse/PFObject+Subclass.h>

@implementation PFAnimal

@dynamic identifier;
@dynamic birthday;
@dynamic specie;
@dynamic photo;
@dynamic animalId;
@dynamic name;
@dynamic notes;
@dynamic breed;
@dynamic sex;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Animal";
}


@end
