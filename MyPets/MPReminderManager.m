//
//  MPReminderManager.m
//  MyPets
//
//  Created by Henrique Morbin on 26/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPReminderManager.h"

@implementation MPReminderManager

+ (int)translateReminderStringToInt:(NSString *)reminder
{
    if ([reminder isEqualToString:kLembreteNaHora]) {
        return 0;
    }else if ([reminder isEqualToString:kLembrete5Minutos]) {
        return 5;
    }else if ([reminder isEqualToString:kLembrete15Minutos]) {
        return 15;
    }else if ([reminder isEqualToString:kLembrete30Minutos]) {
        return 30;
    }else if ([reminder isEqualToString:kLembrete1Hora]) {
        return 60;
    }else if ([reminder isEqualToString:kLembrete2Horas]) {
        return 120;
    }else if ([reminder isEqualToString:kLembrete1Dia]) {
        return 1440;
    }else if ([reminder isEqualToString:kLembrete2Dias]) {
        return 2880;
    }else if ([reminder isEqualToString:kLembrete3Dias]) {
        return 4320;
    }else if ([reminder isEqualToString:kLembrete1Semana]) {
        return 10080;
    }else if ([reminder isEqualToString:kLembrete1Mes]) {
        return 43200;
    }else if ([reminder isEqualToString:kLembreteNunca]) {
        return -1;
    }
    
    return -1;
}

+ (NSString *)translateReminderIntToStrig:(int)reminder
{
    switch (reminder) {
        case 0:
            return kLembreteNaHora;
            break;
        case 5:
            return kLembrete5Minutos;
            break;
        case 15:
            return kLembrete15Minutos;
            break;
        case 30:
            return kLembrete30Minutos;
            break;
        case 60:
            return kLembrete1Hora;
            break;
        case 120:
            return kLembrete2Horas;
            break;
        case 1440:
            return kLembrete1Dia;
            break;
        case 2880:
            return kLembrete2Dias;
            break;
        case 4320:
            return kLembrete3Dias;
            break;
        case 10080:
            return kLembrete1Semana;
            break;
        case 43200:
            return kLembrete1Mes;
            break;
        case -1:
            return kLembreteNunca;
            break;
            
        default:
            return kLembreteNunca;
            break;
    }
    
    return kLembreteNunca;
}

@end
