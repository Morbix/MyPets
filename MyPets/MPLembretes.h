//
//  MPLembretes.h
//  MyPets
//
//  Created by HP Developer on 22/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animal.h"
#import "Vacina.h"
#import "Vermifugo.h"
#import "Consulta.h"
#import "Banho.h"
#import "Medicamento.h"

@interface MPLembretes : NSObject
@property (nonatomic, strong) NSArray *arrayLembretes;

+ (id)shared;
+ (int)getCount;
+ (NSArray *)getNotifications;

- (void)scheduleNotification:(id)object;
- (NSDate *)maskDateFromObject:(id)object;
- (UILocalNotification *)searchNotificationFromObject:(id)object;
- (BOOL)existNotificationFromObject:(id)object;
- (void)clearInvalidNotification;
- (void)deleteNotificationFromObject:(id)object;
- (void)deleteNotificationFromPet:(Animal *)pet;
@end
