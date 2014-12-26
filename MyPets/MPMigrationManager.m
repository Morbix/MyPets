//
//  MPMigrationManager.m
//  MyPets
//
//  Created by Henrique Morbin on 24/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPMigrationManager.h"
#import "MPInternetManager.h"
#import "MPAppDelegate.h"
#import "FCFileManager.h"
#import "MPReminderManager.h"

#import "Animal.h"
#import "PFAnimal.h"

#import "Banho.h"
#import "PFBath.h"

@interface MPMigrationManager ()
{
    NSManagedObjectContext *context;
}
@end

@implementation MPMigrationManager

- (void)startMigration
{
    context = [(MPAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    if ([[MPInternetManager shared] hasInternetConnectionViaWifi]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self startMigrationThreadSafe];
        });
    }
}

- (void)startMigrationThreadSafe
{
    NSArray *arrayPets = [self getAllPets];
    
    if (arrayPets.count > 0) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s Starting Migration...", __PRETTY_FUNCTION__);
        }
        
        BOOL completed = YES;
        
        for (Animal *animal in arrayPets) {
            completed = [[MPInternetManager shared] hasInternetConnectionViaWifi];
            if (!completed) { break; }
            
            PFAnimal *animalMigrated = [self migrateAnimal:animal];
            completed =  animalMigrated ? YES : NO;
            if (!completed) { break; }
            
            if (animal.cArrayBanhos.count > 0) {
                for (Banho *banho in animal.cArrayBanhos.allObjects) {
                    PFBath *bathMigrated = [self migrateBath:banho toAnimal:animalMigrated];
                    completed = bathMigrated ? YES : NO;
                    if (!completed) { break; }
                }
            }
            if (!completed) { break; }
        }
        
        if (MX_DESENV_MODE) {
            if (completed) {
                NSLog(@"%s ###Finishing### Migration...", __PRETTY_FUNCTION__);
            }else{
                NSLog(@"%s ###Stoping### Migration...", __PRETTY_FUNCTION__);
            }
        }
        
        if (MX_DESENV_MODE) {
            NSLog(@"\n\n\n\n");
        }
    }
}

- (PFAnimal *)migrateAnimal:(Animal *)animalToMigrate
{
    NSError *error = nil;
    
    PFAnimal *animalToSave = nil;
    
    NSString *animalName = animalToMigrate.cNome;
    
    NSString *token = nil;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Animal: %@",animalName);
    }
    
    if (animalToMigrate.cIdentifier && ![animalToMigrate.cIdentifier isEqualToString:@""]) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s animal: %@ has already migrated (token: %@)", __PRETTY_FUNCTION__ ,animalName, animalToMigrate.cIdentifier);
        }
        
        animalToSave = [self retrieveObjectWithClass:[PFAnimal class] andToken:animalToMigrate.cIdentifier];
        
        token = animalToMigrate.cIdentifier;
    }else{
        animalToSave = [PFAnimal object];

        token = [self randomStringToken];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting migrate animal: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    
    [animalToSave setIdentifier:token];
    
    if (animalToMigrate.cDataNascimento) {
        [animalToSave setBirthday:animalToMigrate.cDataNascimento];
    }
    if (animalToMigrate.cEspecie) {
        [animalToSave setSpecie:animalToMigrate.cEspecie];
    }
    if (animalToMigrate.cID) {
        [animalToSave setAnimalId:animalToMigrate.cID];
    }
    if (animalToMigrate.cNome) {
        [animalToSave setName:animalToMigrate.cNome];
    }
    if (animalToMigrate.cObs) {
        [animalToSave setNotes:animalToMigrate.cObs];
    }
    if (animalToMigrate.cRaca) {
        [animalToSave setBreed:animalToMigrate.cRaca];
    }
    if (animalToMigrate.cSexo) {
        [animalToSave setSex:animalToMigrate.cSexo];
    }
    
    
    [self savePhoto:animalToMigrate.cFoto withToken:token error:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    
    PFFile *filePhoto = animalToSave.photo;
    if (!filePhoto) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s sending photo: %@", __PRETTY_FUNCTION__ ,token);
        }
        filePhoto = [PFFile fileWithName:token
                                    data:animalToMigrate.cFoto
                             contentType:@"image/png"];
        [filePhoto save:&error];
        if (error) {
            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
            return nil;
        }
        
        if (MX_DESENV_MODE) {
            NSLog(@"%s photo sent: %@", __PRETTY_FUNCTION__ ,token);
        }
        
        [animalToSave setPhoto:filePhoto];
    }
    
    [animalToSave save:&error];
    
    if (error) {
        [animalToSave unpin];
        
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    [animalToSave pin:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    animalToMigrate.cIdentifier = token;
    [context save:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish migrate animal: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return animalToSave;
}

- (PFBath *)migrateBath:(Banho *)bathToMigrate toAnimal:(PFAnimal *)animalMigrated
{
    NSError *error = nil;
    
    PFBath *bathToSave = nil;
    
    NSString * animalName = bathToMigrate.cAnimal.cNome;
    NSString * bathName = bathToMigrate.cData.description;
    
    NSString *token = nil;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Animal: %@ ===> Bath: %@", animalName, bathName);
    }
    
    if (bathToMigrate.cIdentifier && ![bathToMigrate.cIdentifier isEqualToString:@""]) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s bath: %@ has already migrated (token: %@)", __PRETTY_FUNCTION__ ,bathName, bathToMigrate.cIdentifier);
        }
        
        bathToSave = [self retrieveObjectWithClass:[PFBath class] andToken:bathToMigrate.cIdentifier];
        
        token = bathToMigrate.cIdentifier;
    }else{
        bathToSave = [PFBath object];
        
        token = [self randomStringToken];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting migrate bath: %@", __PRETTY_FUNCTION__ ,bathName);
    }
    
    [bathToSave setIdentifier:token];
    [bathToSave setAnimal:animalMigrated];
    
    if (bathToMigrate.cData) {
        if (bathToMigrate.cHorario) {
            [bathToSave setDateAndTime:[self combineDate:bathToMigrate.cData
                                                withTime:bathToMigrate.cHorario]];
        }else{
            [bathToSave setDateAndTime:bathToMigrate.cData];
        }
    }
    if (bathToMigrate.cID) {
        [bathToSave setBathId:bathToMigrate.cID];
    }
    if (bathToMigrate.cLembrete) {
        [bathToSave setReminder:[MPReminderManager translateReminderStringToInt:bathToMigrate.cLembrete]];
    }
    if (bathToMigrate.cObs) {
        [bathToSave setNotes:bathToMigrate.cObs];
    }
    if (bathToMigrate.cPeso) {
        [bathToSave setWeight:bathToMigrate.cPeso.floatValue];
    }
    
    [bathToSave save:&error];
    
    if (error) {
        [bathToSave unpin];
        
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    [bathToSave pin:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    PFRelation *relation = [animalMigrated relationForKey:@"relationOfBath"];
    [relation addObject:bathToSave];
    [animalMigrated save:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    bathToMigrate.cIdentifier = token;
    [context save:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish migrate bath: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return bathToSave;
}

#pragma mark - Core Data
- (NSArray *)getAllPets
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Animal"];
    
    NSError *error;
    
    NSArray *arrayResult = [context executeFetchRequest:request
                                                  error:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s pet count: %d", __PRETTY_FUNCTION__, (int)arrayResult.count);
    }
    
    return arrayResult;
}

#pragma mark - Utils
- (NSString *)randomStringToken
{
    return [self randomStringWithLength:20];
}

- (NSString *)randomStringWithLength:(int)len
{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *s = [NSMutableString stringWithCapacity:len];
    for (NSUInteger i = 0U; i < len; i++)
    {
        u_int32_t r = arc4random() % [alphabet length];
        unichar   c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return [[NSString alloc] initWithString:s];
}

- (void)savePhoto:(NSData *)photo withToken:(NSString *)token  error:(NSError **)error
{
    NSString *filePath = [NSString stringWithFormat:@"photos/%@.png", token];
    
    if ([FCFileManager existsItemAtPath:filePath]) {
        [FCFileManager removeItemAtPath:filePath
                                  error:&*error];
        
        if (*error) {
            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, [*error localizedDescription]);
            return;
        }
    }
    
    [FCFileManager writeFileAtPath:filePath
                           content:photo
                             error:&*error];
    
    if (*error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, [*error localizedDescription]);
        return;
    }
}

- (id)retrieveObjectWithClass:(Class<PFSubclassing>)class andToken:(NSString *)token
{
    PFObject *object = nil;
    
    
    PFQuery *queryLocally = [class query];
    [queryLocally fromLocalDatastore];
    [queryLocally whereKey:@"identifier" equalTo:token];
    object = [queryLocally getFirstObject];
    
    if (object) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s object: %@ retrieved from local datastore", __PRETTY_FUNCTION__, object.objectId);
        }
        return object;
    }
    
    PFQuery *queryRemotely = [class query];
    [queryRemotely whereKey:@"identifier" equalTo:token];
    object = [queryRemotely getFirstObject];
    
    if (object) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s object: %@ retrieved from server", __PRETTY_FUNCTION__, object.objectId);
        }
        return object;
    }
    
    return [class object];
}

- (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlagsDate = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlagsDate fromDate:date];
    unsigned unitFlagsTime = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
    NSDateComponents *timeComponents = [calendar components:unitFlagsTime fromDate:time];
    
    [dateComponents setSecond:[timeComponents second]];
    [dateComponents setHour:[timeComponents hour]];
    [dateComponents setMinute:[timeComponents minute]];
    
    NSDate *combDate = [calendar dateFromComponents:dateComponents];

    if (MX_DESENV_MODE) {
        NSLog(@"\n%@\n%@\n%@", date, time, combDate);
    }
    
    return combDate;
}
@end
