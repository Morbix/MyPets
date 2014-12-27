//
//  PFWeight.m
//  MyPets
//
//  Created by Henrique Morbin on 27/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "PFWeight.h"

@implementation PFWeight

@dynamic owner;
@dynamic identifier;
@dynamic dateAndTime;
@dynamic weightId;
@dynamic notes;
@dynamic weight;
@dynamic animal;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Weight";
}

@end
