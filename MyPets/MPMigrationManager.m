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

#import "Animal.h"
#import "PFAnimal.h"

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
            
            completed = [self migrateAnimal:animal];
            if (!completed) { break; }
        }
        
        if (MX_DESENV_MODE) {
            if (completed) {
                //NSLog(@"%s Finishing Migration...", __PRETTY_FUNCTION__);
            }else{
                NSLog(@"%s Stoping Migration...", __PRETTY_FUNCTION__);
            }
        }
    }
}

- (BOOL)migrateAnimal:(Animal *)animalToMigrate
{
    NSError *error = nil;
    
    PFAnimal *animalToSave = nil;
    
    NSString *animalName = animalToMigrate.cNome;
    
    NSString *token = nil;
    
    if (animalToMigrate.cIdentifier && ![animalToMigrate.cIdentifier isEqualToString:@""]) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s animal: %@ has already migrated (token: %@)", __PRETTY_FUNCTION__ ,animalName, animalToMigrate.cIdentifier);
        }
        
        animalToSave = [self retrieveObjectWithClass:[PFAnimal class] andToken:animalToMigrate.cIdentifier];
        
        token = animalToSave.identifier;
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
        return NO;
    }
    
    
    PFFile *filePhoto = animalToSave.photo;
    if (!filePhoto) {
        filePhoto = [PFFile fileWithData:animalToMigrate.cFoto
                             contentType:@"image/png"];
        [filePhoto save:&error];
        if (error) {
            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
            return NO;
        }
        
        [animalToSave setPhoto:filePhoto];
    }
    
    [animalToSave save:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    [animalToSave pin:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    animalToMigrate.cIdentifier = token;
    [context save:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish migrate animal: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    
    return YES;
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
@end
