//
//  MPSyncManager.m
//  MyPets
//
//  Created by Henrique Morbin on 30/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPSyncManager.h"

#import "MPInternetManager.h"
#import "MPAppDelegate.h"
#import "FCFileManager.h"
#import "MPReminderManager.h"

#import "Animal.h"
#import "PFAnimal.h"

#import "Banho.h"
#import "PFBath.h"

#import "Consulta.h"
#import "PFAppointment.h"

#import "Medicamento.h"
#import "PFMedice.h"

#import "Peso.h"
#import "PFWeight.h"

#import "Vacina.h"
#import "PFVaccine.h"

#import "Vermifugo.h"
#import "PFVermifuge.h"

@interface MPSyncManager ()
{
    NSManagedObjectContext *context;
}
@end

@implementation MPSyncManager

+ (instancetype)shared
{
    static MPSyncManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPSyncManager new];
        
        manager.syncronizationStatus = MPSyncStatusNone;
        
        [manager addObserver:manager forKeyPath:NSStringFromSelector(@selector(syncronizationStatus))
                     options:NSKeyValueObservingOptionNew
                     context:nil];
        
#if !DEBUG
#error CHANGE TIME TO 30
#endif
        [NSTimer scheduledTimerWithTimeInterval:10 target:manager selector:@selector(startSyncronization) userInfo:nil repeats:YES];
    });
    return manager;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(migrationStatus))];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(migrationStatus))]) {
        if ([self.delegate respondsToSelector:@selector(migration:didChangeStatus:)]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.delegate sync:self didChangeStatus:self.syncronizationStatus];
            });
        }
    }
}

#pragma mark - Syncronization
- (void)startSyncronization
{
    if (self.syncronizationStatus != MPSyncStatusInProgress) {
        
        self.syncronizationStatus = MPSyncStatusInProgress;
        
        context = [(MPAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        if ([[MPInternetManager shared] hasInternetConnection]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if ([self startSyncWithThreadSafe]) {
                    self.syncronizationStatus = MPSyncStatusDone;
                }else{
                    self.syncronizationStatus = MPSyncStatusStopped;
                }
            });
        }else{
            self.syncronizationStatus = MPSyncStatusCancelled;
        }
    }else{
        if (MX_DESENV_MODE) {
            NSLog(@"%s Sync in progress...", __PRETTY_FUNCTION__);
        }
    }
}

- (BOOL)startSyncWithThreadSafe
{
    if (MX_DESENV_MODE) {
        NSLog(@"%s Starting Migration...", __PRETTY_FUNCTION__);
    }
    
    BOOL completed = YES;
    
    NSArray *arrayClasses = @[
                              @{@"entityName": @"Animal",      @"class": [PFAnimal class]},
                              @{@"entityName": @"Vacina",      @"class": [PFVaccine class]},
                              @{@"entityName": @"Vermifugo",   @"class": [PFVermifuge class]},
                              @{@"entityName": @"Medicamento", @"class": [PFMedice class]},
                              @{@"entityName": @"Consulta",    @"class": [PFAppointment class]},
                              @{@"entityName": @"Banho",       @"class": [PFBath class]},
                              @{@"entityName": @"Peso",        @"class": [PFWeight class]},
                            ];
    
    
    for (NSDictionary *dict in arrayClasses) {
        completed = [self syncEntityName:dict[@"entityName"] andClass:dict[@"class"]];
        if (!completed) { break;}
        
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
    
    return completed;
}

- (BOOL)syncEntityName:(NSString *)entityName andClass:(Class)class
{
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting sync for: %@", __PRETTY_FUNCTION__, entityName);
    }
    
    BOOL completed = YES;
    
    NSDate *dateLocalLastUpdate = [self mostRecentUpdatedAtDateForEntityWithName:entityName];
    completed = dateLocalLastUpdate ? YES : NO;
    if (!completed) { return completed;}
    if (MX_DESENV_MODE) {
        NSLog(@"%s date local last update %@...", __PRETTY_FUNCTION__, dateLocalLastUpdate);
    }
    
    NSDate *dateRemoteLastUpdate = [self mostRecentUpdatedAtDateForClass:class];
    completed = dateRemoteLastUpdate ? YES : NO;
    if (!completed) { return completed;}
    if (MX_DESENV_MODE) {
        NSLog(@"%s date remote last update %@...", __PRETTY_FUNCTION__, dateRemoteLastUpdate);
    }
    
    
    
    return completed;
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

- (NSDate *)mostRecentUpdatedAtDateForEntityWithName:(NSString *)entityName
{
    __block NSDate *date = nil;
    __block NSError *error = nil;
    //
    // Create a new fetch request for the specified entity
    //
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    //
    // Set the sort descriptors on the request to sort by updatedAt in descending order
    //
    [request setSortDescriptors:[NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
    //
    // You are only interested in 1 result so limit the request to 1
    //
    [request setFetchLimit:1];
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        NSArray *results = [context executeFetchRequest:request error:&error];
        if ([results lastObject])   {
            //
            // Set date to the fetched result
            //
            date = [[results lastObject] valueForKey:@"updatedAt"];
        }else{
            date = [NSDate dateWithTimeIntervalSince1970:0];
        }
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    return date;
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

#pragma mark - Parse Utils
- (void)retrieveOrCreateObjectWithClass:(Class<PFSubclassing>)class andIdentifier:(NSString *)identifier andPutInPFObject:(PFObject **)parseObject andToken:(NSString **)token
{
    if (identifier && ![identifier isEqualToString:@""]) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s object has already migrated (token: %@)", __PRETTY_FUNCTION__, identifier);
        }
        
        *parseObject = [self retrieveObjectWithClass:class andToken:identifier];
        
        *token = identifier;
    }else{
        *parseObject = [class object];
        
        *token = [self randomStringToken];
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

- (NSDate *)mostRecentUpdatedAtDateForClass:(Class <PFSubclassing>)class
{
    NSError *error;
    
    NSDate *dateLastUpdated = nil;
    
    PFQuery *query = [class query];
    
    [query setLimit:1];
    [query orderByDescending:@"updatedAt"];
    NSArray *arrayObjects = [query findObjects:&error];
    if (!error) {
        if (arrayObjects && (arrayObjects.count > 0)) {
            PFObject *object = [arrayObjects lastObject];
            dateLastUpdated = [object updatedAt];
        }else{
            dateLastUpdated = [NSDate dateWithTimeIntervalSince1970:0];
        }
    }else{
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
        return nil;
    }
    
    return dateLastUpdated;
}
@end
