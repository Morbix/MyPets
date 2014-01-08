//
//  MPLembretes.m
//  MyPets
//
//  Created by HP Developer on 22/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPLembretes.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"


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

+ (int)getCount
{
    return [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
}

+ (NSArray *)getNotifications
{
    return [[UIApplication sharedApplication] scheduledLocalNotifications];
}

- (void)scheduleNotification:(id)object
{
    NSString * _alertBody = @"";
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:NSLS(@"dd.MM.yyyy hh:mm a")];
    NSString *analytics = @"";
    
    if ([object isKindOfClass:[Medicamento class]]) {
        Medicamento * med = (Medicamento *)object; analytics = @"Lembrete Medicamento";
        
        _alertBody = [NSString stringWithFormat:@"%@ %@ %@\n%@",NSLocalizedString(@"Lembrete",nil),med.cNome,med.cAnimal.cNome,[formatter stringFromDate:med.cData]];
    }else if ([object isKindOfClass:[Banho class]]) {
        Banho * ban = (Banho *)object; analytics = @"Lembrete Banho";
        
        _alertBody = [NSString stringWithFormat:@"%@ %@ %@\n%@",NSLocalizedString(@"Lembrete",nil),NSLocalizedString(@"Banho",nil),ban.cAnimal.cNome,[formatter stringFromDate:ban.cData]];
    }else if ([object isKindOfClass:[Consulta class]]) {
        Consulta * con = (Consulta *)object; analytics = @"Lembrete Consulta";
        
        _alertBody = [NSString stringWithFormat:@"%@ %@ %@\n%@",NSLocalizedString(@"Lembrete",nil),NSLocalizedString(@"Consulta",nil),con.cAnimal.cNome,[formatter stringFromDate:con.cData]];
    }else if ([object isKindOfClass:[Vacina class]]) {
        Vacina * van = (Vacina *)object; analytics = @"Lembrete Vacina";
        
        _alertBody = [NSString stringWithFormat:@"%@ %@ %@\n%@",NSLocalizedString(@"Lembrete",nil),NSLocalizedString(@"Vacina",nil),van.cAnimal.cNome,[formatter stringFromDate:van.cData]];
    }else if ([object isKindOfClass:[Vermifugo class]]) {
        Vermifugo * ver = (Vermifugo *)object; analytics = @"Lembrete Vermífugo";
        
        _alertBody = [NSString stringWithFormat:@"%@ %@ %@\n%@",NSLocalizedString(@"Lembrete",nil),NSLocalizedString(@"Vermífugo",nil),ver.cAnimal.cNome,[formatter stringFromDate:ver.cData]];
    }

    
    UILocalNotification *localNotification = [self searchNotificationFromObject:object];
    
    localNotification.fireDate    = [self maskDateFromObject:object];
    localNotification.timeZone    = [NSTimeZone defaultTimeZone];
    localNotification.alertBody   = _alertBody;
    localNotification.alertAction = NSLocalizedString(@"Abrir",nil);
	localNotification.soundName   = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 0;
    
	NSDictionary * infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:[object valueForKey:@"cID"],@"cID", nil];
    localNotification.userInfo = infoDict;
    
    if (![[object valueForKey:@"cID"] isEqualToString:@""]) {
        if (localNotification.fireDate) {
            if ([localNotification.fireDate timeIntervalSinceNow] > 1) {
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                
                int interval = (int)floor([localNotification.fireDate timeIntervalSinceNow]);
                                          
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Lembrete" action:analytics label:analytics value:[NSNumber numberWithInt:(int)(interval/86400)]] build]];
            }
        }
    }
    
    //[localNotification release]; localNotification = nil;
}



- (NSDate *)maskDateFromObject:(id)object
{
    NSDate * _date      = [object valueForKey:@"cData"] ? [object valueForKey:@"cData"] : [NSDate date];
    NSString *_lembrete = [object valueForKey:@"cLembrete"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit  | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:_date];
    NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit  | NSMinuteCalendarUnit ) fromDate:_date];
	
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setTimeZone:calendar.timeZone];
    [dateComps setDay:[dateComponents day]];
    [dateComps setMonth:[dateComponents month]];
    [dateComps setYear:[dateComponents year]];
    [dateComps setHour:[timeComponents hour]];
    [dateComps setMinute:[timeComponents minute]];
	[dateComps setSecond:0];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    
    NSDateComponents *offSet = [[NSDateComponents alloc] init];
    [offSet setTimeZone:calendar.timeZone];
    
    if ([_lembrete isEqualToString:kLembreteNaHora]) {
        return itemDate;
    }else if ([_lembrete isEqualToString:kLembrete5Minutos]) {
        [offSet setMinute:-5];
        
        itemDate = [calendar dateByAddingComponents:offSet toDate:itemDate options:0];
        return itemDate;
    }else if ([_lembrete isEqualToString:kLembrete15Minutos]) {
        [offSet setMinute:-15];
        
        itemDate = [calendar dateByAddingComponents:offSet toDate:itemDate options:0];
        return itemDate;
    }else if ([_lembrete isEqualToString:kLembrete30Minutos]) {
        [offSet setMinute:-30];
        
        itemDate = [calendar dateByAddingComponents:offSet toDate:itemDate options:0];
        return itemDate;
    }else if ([_lembrete isEqualToString:kLembrete1Hora]) {
        [offSet setHour:-1];
        
        itemDate = [calendar dateByAddingComponents:offSet toDate:itemDate options:0];
        return itemDate;
    }else if ([_lembrete isEqualToString:kLembrete2Horas]) {
        [offSet setHour:-2];
        
        itemDate = [calendar dateByAddingComponents:offSet toDate:itemDate options:0];
        return itemDate;
    }else if ([_lembrete isEqualToString:kLembrete1Dia]) {
        [offSet setDay:-1];
        
        itemDate = [calendar dateByAddingComponents:offSet toDate:itemDate options:0];
        return itemDate;
    }else if ([_lembrete isEqualToString:kLembrete2Dias]) {
        [offSet setDay:-2];
        
        itemDate = [calendar dateByAddingComponents:offSet toDate:itemDate options:0];
        return itemDate;
    }else if ([_lembrete isEqualToString:kLembrete3Dias]) {
        [offSet setDay:-3];
        
        itemDate = [calendar dateByAddingComponents:offSet toDate:itemDate options:0];
        return itemDate;
    }else if ([_lembrete isEqualToString:kLembrete1Semana]) {
        [offSet setWeek:-1];
        
        itemDate = [calendar dateByAddingComponents:offSet toDate:itemDate options:0];
        return itemDate;
    }else if ([_lembrete isEqualToString:kLembrete1Mes]) {
        [offSet setMonth:-1];
        
        itemDate = [calendar dateByAddingComponents:offSet toDate:itemDate options:0];
        return itemDate;
    }else if ([_lembrete isEqualToString:kLembreteNunca]) {
        [offSet setYear:-1];
        
        itemDate = [calendar dateByAddingComponents:offSet toDate:[NSDate date] options:0];
        return itemDate;
    }
    
    
    return nil;
}


- (UILocalNotification *)searchNotificationFromObject:(id)object
{
    [self clearInvalidNotification];
    
    NSArray * array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification * noti in array) {
        NSString * notiID = [noti.userInfo valueForKey:@"cID"];
        NSString * objectID  = [object valueForKey:@"cID"];
        if ([notiID isEqualToString:objectID]) {
            [[UIApplication sharedApplication] cancelLocalNotification:noti];
        }
    }
    
    return [[UILocalNotification alloc] init];
}



- (BOOL)existNotificationFromObject:(id)object
{
    [self clearInvalidNotification];
    
    NSArray * array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification * noti in array) {
        NSString * notiID = [noti.userInfo valueForKey:@"cID"];
        NSString * objectID  = [object valueForKey:@"cID"];
        if ([notiID isEqualToString:objectID]) {
            return TRUE;
        }
    }
    return FALSE;
}

- (void)clearInvalidNotification
{
    NSArray * array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification * noti in array) {
        NSString * notiID = [noti.userInfo valueForKey:@"cID"];
        if (([notiID isEqualToString:@""]) || (!notiID)) {
            [[UIApplication sharedApplication] cancelLocalNotification:noti];
        }
    }
}

- (void)deleteNotificationFromObject:(id)object
{
    NSArray * array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification * noti in array) {
        NSString * notiID = [noti.userInfo valueForKey:@"cID"];
        NSString * objectID  = [object valueForKey:@"cID"];
        if ([notiID isEqualToString:objectID]) {
            [[UIApplication sharedApplication] cancelLocalNotification:noti];
        }
    }
}

- (void)deleteNotificationFromPet:(Animal *)pet
{
    for (Medicamento * med in pet.cArrayMedicamentos) {
        [self deleteNotificationFromObject:med];
    }
    
    for (Banho * ban in pet.cArrayBanhos) {
        [self deleteNotificationFromObject:ban];
    }
    
    for (Consulta * con in pet.cArrayConsultas) {
        [self deleteNotificationFromObject:con];
    }
    
    for (Vacina * van in pet.cArrayVacinas) {
        [self deleteNotificationFromObject:van];
    }
    
    for (Vermifugo * ver in pet.cArrayVermifugos) {
        [self deleteNotificationFromObject:ver];
    }
}
@end
