//
//  PFBanho.m
//  MyPets
//
//  Created by Henrique Morbin on 26/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "PFBath.h"

@implementation PFBath

@dynamic owner;
@dynamic identifier;
@dynamic dateAndTime;
@dynamic bathId;
@dynamic reminder;
@dynamic notes;
@dynamic weight;
@dynamic animal;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Bath";
}

@end
