//
//  MPReminderManager.h
//  MyPets
//
//  Created by Henrique Morbin on 26/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPReminderManager : NSObject

+ (int)translateReminderStringToInt:(NSString *)reminder;
+ (NSString *)translateReminderIntToStrig:(int)reminder;
@end
