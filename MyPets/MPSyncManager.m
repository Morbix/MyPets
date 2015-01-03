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
#import "Sync.h"

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

@end

@implementation MPSyncManager

+ (instancetype)shared
{
    static MPSyncManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPSyncManager new];
        
        manager.syncronizationStatus = MPSyncStatusNone;
        
        manager.context = [(MPAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        manager.syncDates = [manager getSyncDates];
        
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
        
        if ([[MPInternetManager shared] hasInternetConnection] && [PFUser currentUser]) {
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
                              @{@"entityName": @"Animal",      @"class": [PFAnimal class],      @"fieldName": @"classAnimal"},
                              @{@"entityName": @"Vacina",      @"class": [PFVaccine class],     @"fieldName": @"classVaccine"},
                              @{@"entityName": @"Vermifugo",   @"class": [PFVermifuge class],   @"fieldName": @"classVermifuge"},
                              @{@"entityName": @"Medicamento", @"class": [PFMedice class],      @"fieldName": @"classMedicine"},
                              @{@"entityName": @"Consulta",    @"class": [PFAppointment class], @"fieldName": @"classAppointment"},
                              @{@"entityName": @"Banho",       @"class": [PFBath class],        @"fieldName": @"classBath"},
                              @{@"entityName": @"Peso",        @"class": [PFWeight class],      @"fieldName": @"classWeight"},
                            ];
    
    
    for (NSDictionary *dict in arrayClasses) {
        completed = [self syncEntityName:dict[@"entityName"] andClass:dict[@"class"] fieldName:dict[@"fieldName"]];
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

- (BOOL)syncEntityName:(NSString *)entityName andClass:(Class)class fieldName:(NSString *)fieldNameForLastUpdatedDate
{
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting sync for: %@", __PRETTY_FUNCTION__, entityName);
    }
    
    BOOL completed = YES;
    
    NSDate *dateLastUpdate = [self.syncDates valueForKey:fieldNameForLastUpdatedDate];
    completed = dateLastUpdate ? YES : NO;
    if (!completed) { return completed;}
    if (MX_DESENV_MODE) {
        NSLog(@"%s date last update %@", __PRETTY_FUNCTION__, dateLastUpdate);
    }

    NSArray *arrayCoreDataObjects = [self getAllObjectsWithEntityName:entityName andLastUpdateNilOfGreaterThan:dateLastUpdate];
    completed = arrayCoreDataObjects ? YES : NO;
    if (!completed) { return completed;}
    if (MX_DESENV_MODE) {
        NSLog(@"%s number of entity: %@ need sync: %d", __PRETTY_FUNCTION__, entityName, (int)arrayCoreDataObjects.count);
    }
    
    NSArray *arrayParseObjects = [self getAllObjectsWithClass:class andLastUpdateNilOfGreaterThan:dateLastUpdate];
    completed = arrayParseObjects ? YES : NO;
    if (!completed) { return completed;}
    if (MX_DESENV_MODE) {
        NSLog(@"%s number of class: %@ need sync: %d", __PRETTY_FUNCTION__, NSStringFromClass(class), (int)arrayParseObjects.count);
    }
    
    if ((arrayCoreDataObjects.count+arrayParseObjects.count) > 0) {
        
        for (NSManagedObject *coreDataObject in arrayCoreDataObjects) {
            if ([self canSyncCoreData:coreDataObject arrayParse:arrayParseObjects]) {
                //sync core data object
                completed = [self syncObject:coreDataObject forEntityName:entityName];
                if (!completed) { return completed;}
            }
        }
        
        for (PFObject *parseObject in arrayParseObjects) {
            if ([self canSyncParse:parseObject arrayCoreData:arrayCoreDataObjects]) {
                //sync parse object
                completed = [self syncObject:parseObject forClassName:NSStringFromClass(class)];
                if (!completed) { return completed;}
            }
        }
    }
    
    __block NSError *error = nil;
    
    [self.syncDates setValue:[NSDate date] forKey:fieldNameForLastUpdatedDate];
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        [self.context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    return completed;
}

- (BOOL)syncObject:(NSManagedObject *)object forEntityName:(NSString *)entityName
{
    if ([entityName isEqualToString:@"Animal"]) {
        return [self _syncCoreDataAnimal:(Animal *)object];
    }else if ([entityName isEqualToString:@"Vacina"]) {
        
    }else if ([entityName isEqualToString:@"Vermifugo"]) {
        
    }else if ([entityName isEqualToString:@"Medicamento"]) {
        
    }else if ([entityName isEqualToString:@"Consulta"]) {
        
    }else if ([entityName isEqualToString:@"Banho"]) {
        
    }else if ([entityName isEqualToString:@"Peso"]) {
        
    }
    
    return YES;
}

- (BOOL)syncObject:(PFObject *)object forClassName:(NSString *)className
{
#warning NEED UI NOTIFICATION
    if ([className isEqualToString:@"PFAnimal"]) {
        return [self _syncParseAnimal:(PFAnimal *)object];
    }else if ([className isEqualToString:@"PFVaccine"]) {
        
    }else if ([className isEqualToString:@"PFVermifuge"]) {
        
    }else if ([className isEqualToString:@"PFMedicine"]) {
        
    }else if ([className isEqualToString:@"PFAppointment"]) {
        
    }else if ([className isEqualToString:@"PFBath"]) {
        
    }else if ([className isEqualToString:@"PFWeight"]) {
        
    }
    
    return YES;
}

- (BOOL)canSyncCoreData:(NSManagedObject *)object arrayParse:(NSArray *)arrayParse
{
    NSString *coreDataIdentifier = [object valueForKey:@"cIdentifier"];
    
    if (!coreDataIdentifier || [coreDataIdentifier isEqualToString:@""] || coreDataIdentifier.length > 15) {
        return YES;
    }
    
    NSDate *coreDataUpdatedAt = [object valueForKey:@"updatedAt"];
    
    if (!coreDataUpdatedAt) {
        coreDataUpdatedAt = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    for (PFObject *parseObject in arrayParse) {
        if ([parseObject.objectId isEqualToString:coreDataIdentifier]) {
            if (parseObject.updatedAt > coreDataUpdatedAt) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)canSyncParse:(PFObject *)object arrayCoreData:(NSArray *)arrayCoreData
{
    for (NSManagedObject *coreDataObject in arrayCoreData) {
        NSString *coreDataIdentifier = [coreDataObject valueForKey:@"cIdentifier"];
        if (!coreDataIdentifier || [coreDataIdentifier isEqualToString:@""] || coreDataIdentifier.length > 15) {
            continue;
        }else{
            if ([coreDataIdentifier isEqualToString:object.objectId]) {
                NSDate *coreDataUpdatedAt = [coreDataObject valueForKey:@"updatedAt"];
                
                if (!coreDataUpdatedAt) {
                    coreDataUpdatedAt = [NSDate dateWithTimeIntervalSince1970:0];
                }
                
                if (coreDataUpdatedAt > object.updatedAt) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - Sync Core Data Objects
- (BOOL)_syncCoreDataAnimal:(Animal *)animalToMigrate
{
    __block NSError *error = nil;
    
    PFAnimal *animalToSave = nil;
    
    NSString *animalName = animalToMigrate.cNome;

    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Core Data Animal: %@",animalName);
    }
    
    if (animalToMigrate.cIdentifier && ![animalToMigrate.cIdentifier isEqualToString:@""] && (animalToMigrate.cIdentifier.length < 15)) {
        animalToSave = [PFAnimal objectWithoutDataWithObjectId:animalToMigrate.cIdentifier];
    }else{
        animalToSave = [PFAnimal object];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting sync animal: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    
    [animalToSave setOwner:[PFUser currentUser]];
    
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
    
    
    if (animalToMigrate.cFoto) {

        if (MX_DESENV_MODE) {
            NSLog(@"%s sending photo", __PRETTY_FUNCTION__);
        }
        PFFile *filePhoto = [PFFile fileWithData:animalToMigrate.cFoto
                             contentType:@"image/png"];
        [filePhoto save:&error];
        if (error) {
            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
            return NO;
        }
        
        if (MX_DESENV_MODE) {
            NSLog(@"%s photo sent", __PRETTY_FUNCTION__);
        }
        
        [animalToSave setPhoto:filePhoto];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving animal: %@", __PRETTY_FUNCTION__ , animalName);
    }
    [animalToSave save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        if (error.code == 101) {
            error = nil;
            animalToMigrate.cIdentifier = @"";
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                [self.context save:&error];
            });
            if (error) {
                NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                return NO;
            }
        }
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    animalToMigrate.cIdentifier = [animalToSave objectId];
    animalToMigrate.updatedAt   = [animalToSave updatedAt];
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        [self.context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving relation between user and animal: %@", __PRETTY_FUNCTION__ , animalName);
    }
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"relationOfAnimal"];
    [relation addObject:animalToSave];
    [[PFUser currentUser] save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish sync animal: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return YES;
}

#pragma mark - Sync Parse Objects
- (BOOL)_syncParseAnimal:(PFAnimal *)animalToMigrate
{
    __block NSError *error = nil;
    
    NSString *animalName = animalToMigrate.name;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Parse Animal: %@",animalName);
    }
    
    Animal *animalToSave = [self retrieveCoreDataObjectWithEntityName:@"Animal"
                                                            andObjectId:animalToMigrate.objectId];
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting sync animal: %@", __PRETTY_FUNCTION__, animalName);
    }
    
    if (animalToMigrate.birthday) {
        animalToSave.cDataNascimento = animalToMigrate.birthday;
    }
    if (animalToMigrate.specie) {
        animalToSave.cEspecie = animalToMigrate.specie;
    }
    if (animalToMigrate.animalId) {
        animalToSave.cID = animalToMigrate.animalId;
    }
    if (animalToMigrate.name) {
        animalToSave.cNome = animalToMigrate.name;
    }
    if (animalToMigrate.notes) {
        animalToSave.cObs = animalToMigrate.notes;
    }
    if (animalToMigrate.breed) {
        animalToSave.cRaca = animalToMigrate.breed;
    }
    if (animalToMigrate.sex) {
        animalToSave.cSexo = animalToMigrate.sex;
    }
    if (animalToMigrate.photo) {
        if (animalToMigrate.photo.isDataAvailable) {
            if (MX_DESENV_MODE) {
                NSLog(@"%s downloading photo", __PRETTY_FUNCTION__);
            }
            NSData *photoData = [animalToMigrate.photo getData:&error];
            if (error) {
                NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                return NO;
            }
            animalToSave.cFoto = photoData;
            if (MX_DESENV_MODE) {
                NSLog(@"%s photo downloaded", __PRETTY_FUNCTION__);
            }
        }
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    animalToSave.cIdentifier = animalToMigrate.objectId;
    animalToSave.updatedAt = animalToMigrate.updatedAt;
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        [self.context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish sync animal: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return YES;
}

#pragma mark - Core Data Utils
- (Sync *)getSyncDates
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync"];
    
    NSError *error;
    
    NSArray *arrayResult = [self.context executeFetchRequest:request
                                                  error:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (arrayResult.count > 0) {
        return [arrayResult firstObject];
    }else{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sync" inManagedObjectContext:self.context];
                                       
        Sync *sync = [[Sync alloc] initWithEntity:entity
                   insertIntoManagedObjectContext:self.context];
        [sync initEmptyDates];
        [self.context save:nil];
        return sync;
    }
    
}

- (NSArray *)getAllObjectsWithEntityName:(NSString *)entityName andLastUpdateNilOfGreaterThan:(NSDate *)lastUpdateRef
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((updatedAt == nil) || (updatedAt > %@))", lastUpdateRef];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    
    [request setPredicate:predicate];
    
    NSError *error;
    
    NSArray *arrayResult = [self.context executeFetchRequest:request
                                                       error:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    return arrayResult;
    
}

- (id)retrieveCoreDataObjectWithEntityName:(NSString *)entityName andObjectId:(NSString *)objectId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(cIdentifier == %@)", objectId];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSError *error;
    
    NSArray *arrayResult = [self.context executeFetchRequest:request
                                                       error:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (arrayResult.count > 0) {
        return [arrayResult lastObject];
    }else{
        return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
    }
    
    return arrayResult;
}
//- (NSArray *)getAllPets
//{
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Animal"];
//    
//    NSError *error;
//    
//    NSArray *arrayResult = [self.context executeFetchRequest:request
//                                                  error:&error];
//    
//    if (error) {
//        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
//        return nil;
//    }
//    
//    if (MX_DESENV_MODE) {
//        NSLog(@"%s pet count: %d", __PRETTY_FUNCTION__, (int)arrayResult.count);
//    }
//    
//    return arrayResult;
//}

//- (NSDate *)mostRecentUpdatedAtDateForEntityWithName:(NSString *)entityName
//{
//    __block NSDate *date = nil;
//    __block NSError *error = nil;
//    //
//    // Create a new fetch request for the specified entity
//    //
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
//    //
//    // Set the sort descriptors on the request to sort by updatedAt in descending order
//    //
//    [request setSortDescriptors:[NSArray arrayWithObject:
//                                 [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
//    //
//    // You are only interested in 1 result so limit the request to 1
//    //
//    [request setFetchLimit:1];
//    dispatch_sync(dispatch_get_main_queue(), ^(void) {
//        NSArray *results = [self.context executeFetchRequest:request error:&error];
//        if ([results lastObject])   {
//            //
//            // Set date to the fetched result
//            //
//            date = [[results lastObject] valueForKey:@"updatedAt"];
//        }else{
//            date = [NSDate dateWithTimeIntervalSince1970:0];
//        }
//    });
//    if (error) {
//        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
//        return nil;
//    }
//    
//    return date;
//}

#pragma mark - Parse Utils
- (NSArray *)getAllObjectsWithClass:(Class<PFSubclassing>)class andLastUpdateNilOfGreaterThan:(NSDate *)lastUpdateRef
{
    PFQuery *query = [class query];
    
    [query whereKey:@"updatedAt" greaterThan:lastUpdateRef];
    
    NSError *error = nil;

    NSArray *arrayResults = [query findObjects:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    return arrayResults;
}

//- (void)retrieveOrCreateObjectWithClass:(Class<PFSubclassing>)class andIdentifier:(NSString *)identifier andPutInPFObject:(PFObject **)parseObject andToken:(NSString **)token
//{
//    if (identifier && ![identifier isEqualToString:@""]) {
//        if (MX_DESENV_MODE) {
//            NSLog(@"%s object has already migrated (token: %@)", __PRETTY_FUNCTION__, identifier);
//        }
//
//        *parseObject = [self retrieveObjectWithClass:class andToken:identifier];
//
//        *token = identifier;
//    }else{
//        *parseObject = [class object];
//
//        *token = [self randomStringToken];
//    }
//}
//
//- (id)retrieveObjectWithClass:(Class<PFSubclassing>)class andToken:(NSString *)token
//{
//    PFObject *object = nil;
//
//
//    PFQuery *queryLocally = [class query];
//    [queryLocally fromLocalDatastore];
//    [queryLocally whereKey:@"identifier" equalTo:token];
//    object = [queryLocally getFirstObject];
//
//    if (object) {
//        if (MX_DESENV_MODE) {
//            NSLog(@"%s object: %@ retrieved from local datastore", __PRETTY_FUNCTION__, object.objectId);
//        }
//        return object;
//    }
//
//    PFQuery *queryRemotely = [class query];
//    [queryRemotely whereKey:@"identifier" equalTo:token];
//    object = [queryRemotely getFirstObject];
//
//    if (object) {
//        if (MX_DESENV_MODE) {
//            NSLog(@"%s object: %@ retrieved from server", __PRETTY_FUNCTION__, object.objectId);
//        }
//        return object;
//    }
//
//    return [class object];
//}

//- (NSDate *)mostRecentUpdatedAtDateForClass:(Class <PFSubclassing>)class
//{
//    NSError *error;
//
//    NSDate *dateLastUpdated = nil;
//
//    PFQuery *query = [class query];
//
//    [query setLimit:1];
//    [query orderByDescending:@"updatedAt"];
//    NSArray *arrayObjects = [query findObjects:&error];
//    if (!error) {
//        if (arrayObjects && (arrayObjects.count > 0)) {
//            PFObject *object = [arrayObjects lastObject];
//            dateLastUpdated = [object updatedAt];
//        }else{
//            dateLastUpdated = [NSDate dateWithTimeIntervalSince1970:0];
//        }
//    }else{
//        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
//        return nil;
//    }
//
//    return dateLastUpdated;
//}


#pragma mark - General Utils
//- (NSString *)randomStringToken
//{
//    return [self randomStringWithLength:20];
//}
//
//- (NSString *)randomStringWithLength:(int)len
//{
//    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
//    
//    NSMutableString *s = [NSMutableString stringWithCapacity:len];
//    for (NSUInteger i = 0U; i < len; i++)
//    {
//        u_int32_t r = arc4random() % [alphabet length];
//        unichar   c = [alphabet characterAtIndex:r];
//        [s appendFormat:@"%C", c];
//    }
//    return [[NSString alloc] initWithString:s];
//}

//- (void)savePhoto:(NSData *)photo withToken:(NSString *)token  error:(NSError **)error
//{
//    NSString *filePath = [NSString stringWithFormat:@"photos/%@.png", token];
//    
//    if ([FCFileManager existsItemAtPath:filePath]) {
//        [FCFileManager removeItemAtPath:filePath
//                                  error:&*error];
//        
//        if (*error) {
//            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, [*error localizedDescription]);
//            return;
//        }
//    }
//    
//    [FCFileManager writeFileAtPath:filePath
//                           content:photo
//                             error:&*error];
//    
//    if (*error) {
//        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, [*error localizedDescription]);
//        return;
//    }
//}

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
