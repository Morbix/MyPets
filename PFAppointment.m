//
//  PFAppointment.m
//  MyPets
//
//  Created by Henrique Morbin on 26/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "PFAppointment.h"

@implementation PFAppointment

@dynamic owner;
@dynamic identifier;
@dynamic dateAndTime;
@dynamic appointmentId;
@dynamic reminder;
@dynamic notes;
@dynamic animal;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Appointment";
}

@end
