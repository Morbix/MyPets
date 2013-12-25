//
//  MPLembretes.m
//  MyPets
//
//  Created by HP Developer on 22/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPLembretes.h"

@implementation MPLembretes
+(id)shared
{
    static MPLembretes *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPLembretes new];
        manager.arrayLembretes = [[NSArray alloc] initWithObjects:kLembreteNunca, kLembreteNaHora, kLembrete5Minutos, kLembrete15Minutos, kLembrete30Minutos, kLembrete1Hora, kLembrete2Horas, kLembrete1Dia, kLembrete2Dias, kLembrete3Dias, kLembrete1Semana, kLembrete1Mes, nil];
    });
    return manager;
}
@end
