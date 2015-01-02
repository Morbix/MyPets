//
//  Sync.m
//  MyPets
//
//  Created by Henrique Morbin on 02/01/15.
//  Copyright (c) 2015 Henrique Morbin. All rights reserved.
//

#import "Sync.h"


@implementation Sync

@dynamic classAnimal;
@dynamic classBath;
@dynamic classAppointment;
@dynamic classMedicine;
@dynamic classWeight;
@dynamic classVaccine;
@dynamic classVermifuge;

- (void)initEmptyDates
{
    if (!self.classAnimal) {
        self.classAnimal = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if (!self.classBath) {
        self.classBath = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if (!self.classAppointment) {
        self.classAppointment = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if (!self.classMedicine) {
        self.classMedicine = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if (!self.classWeight) {
        self.classWeight = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if (!self.classVaccine) {
        self.classVaccine = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if (!self.classVermifuge) {
        self.classVermifuge = [NSDate dateWithTimeIntervalSince1970:0];
    }
}

@end
