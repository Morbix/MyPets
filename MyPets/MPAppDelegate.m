//
//  MPAppDelegate.m
//  MyPets
//
//  Created by Henrique Morbin on 23/10/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPAppDelegate.h"
#import "MPLibrary.h"
#import "Appirater.h"
#import <Parse/Parse.h>
#import <Dropbox/Dropbox.h>
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "MPDropboxNotification.h"

#define kSIZE 10

@implementation MPAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[MPLibrary appearanceCustom];
    
    [Appirater setAppId:[MPTargets targetAppID]];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    
    
    [Parse setApplicationId:@"VOfi2AierOCqzfMPjFWkUeAVAM4tjT7ODkzqSCOm" clientKey:@"8byEO3HfZvG5vhaNnPeZ5jY76dW4AkWXl7acnV8D"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    [[GAI sharedInstance] trackerWithTrackingId:[MPTargets targetAnalyticsID]];
    //[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Application" action:@"Launching"  label:@"Launching" value:nil] build]];    // Event value
    
    /*[MPDropboxNotification shared];
    
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:DropboxAppKey secret:DropboxAppSecret];
    [DBAccountManager setSharedManager:accountManager];
    
    if ([accountManager linkedAccount]) {
        [self setSyncEnabled:YES];
    }*/
    
    
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif){
        NSLog(@"Recieved Notification [1]");
    }
    
    return YES;
}

#pragma mark - LocalNotification
- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (notification) {
        NSLog(@"Recieved Notification [2]");
        if ([app applicationState] == UIApplicationStateActive) {
            if (!_notificationAlert) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [self setNotificationAlert:alert];
            }
            
            [_notificationAlert setTitle:[notification alertBody]];

            [_notificationAlert show];
        }
    }
}

#pragma mark - Dropbox
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        return YES;
    }
    return NO;
}

- (void)setSyncEnabled:(BOOL)enabled
{
    DBAccountManager *accountManager = [DBAccountManager sharedManager];
    
    if (enabled) {
        if (!self.syncManager) {
            DBAccount *account = [accountManager linkedAccount];
            
            if (account) {
                __weak typeof(self) weakSelf = self;
                [accountManager addObserver:self block:^(DBAccount *account) {
                    typeof(self) strongSelf = weakSelf; if (!strongSelf) return;
                    if (![account isLinked]) {
                        [strongSelf setSyncEnabled:NO];
                        NSLog(@"Unlinked account: %@", account);
                    }
                }];
                
                DBError *dberror = nil;
                DBDatastore *datastore = [DBDatastore openDefaultStoreForAccount:account error:&dberror];
                if (datastore) {
                    self.syncManager = [[PKSyncManager alloc] initWithManagedObjectContext:self.managedObjectContext datastore:datastore];
                    [self.syncManager setTablesForEntityNamesWithDictionary:@{@"Animal": @"animal", @"Banho": @"banho", @"Consulta": @"consulta", @"Medicamento": @"medicamento", @"Peso": @"peso", @"Vacina": @"vacina", @"Vermifugo": @"vermifugo"}];
                    
                    NSError *error = nil;
                    if (![self addMissingSyncAttributeValueToCoreDataObjects:&error]) {
                        NSLog(@"Error adding missing sync attribute value to Core Data objects: %@", error);
                    } else if ([[datastore getTables:nil] count] == 0) {
                        if (![self updateDropboxFromCoreData:&error]) {
                            NSLog(@"Error updating Dropbox from Core Data: %@", error);
                        }
                    }
                } else {
                    NSLog(@"Error opening default datastore: %@", dberror);
                }
            }
        }
        
        [self.syncManager startObserving];
    } else {
        [self.syncManager stopObserving];
        self.syncManager = nil;
        
        [accountManager removeObserver:self];
    }
}

- (BOOL)addMissingSyncAttributeValueToCoreDataObjects:(NSError **)error
{
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [managedObjectContext setUndoManager:nil];
    
    NSString *syncAttributeName = self.syncManager.syncAttributeName;
    NSArray *entityNames = [self.syncManager entityNames];
    for (NSString *entityName in entityNames) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == nil", syncAttributeName]];
        [fetchRequest setFetchBatchSize:kSIZE];
        
        NSArray *objects = [managedObjectContext executeFetchRequest:fetchRequest error:error];
        if (objects) {
            for (NSManagedObject *managedObject in objects) {
                if (![managedObject valueForKey:syncAttributeName]) {
                    [managedObject setValue:[PKSyncManager syncID] forKey:syncAttributeName];
                }
            }
        } else {
            return NO;
        }
    }
    
    if ([managedObjectContext hasChanges]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncManagedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        BOOL saved = [managedObjectContext save:error];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        return saved;
    }
    
    return YES;
}

- (BOOL)updateDropboxFromCoreData:(NSError **)error
{
    __block BOOL result = YES;
    NSManagedObjectContext *managedObjectContext = self.syncManager.managedObjectContext;
    DBDatastore *datastore = self.syncManager.datastore;
    NSString *syncAttributeName = self.syncManager.syncAttributeName;
    
    NSDictionary *tablesByEntityName = [self.syncManager tablesByEntityName];
    [tablesByEntityName enumerateKeysAndObjectsUsingBlock:^(NSString *entityName, NSString *tableId, BOOL *stop) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [fetchRequest setFetchBatchSize:kSIZE];
        
        NSArray *managedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:error];
        if (managedObjects) {
            for (NSManagedObject *managedObject in managedObjects) {
                DBTable *table = [datastore getTable:tableId];
                DBError *dberror = nil;
                DBRecord *record = [table getOrInsertRecord:[managedObject valueForKey:syncAttributeName] fields:nil inserted:NULL error:&dberror];
                if (record) {
                    [record pk_setFieldsWithManagedObject:managedObject syncAttributeName:syncAttributeName];
                    DBError *dberror = nil;
                    [datastore sync:&dberror];
                    if (dberror) {
                        NSLog(@"--: %@",dberror.description);
                    }
                } else {
                    if (error) {
                        *error = [NSError errorWithDomain:[dberror domain] code:[dberror code] userInfo:[dberror userInfo]];
                    }
                    result = NO;
                    *stop = YES;
                }
            }
        } else {
            *stop = YES;
        }
    }];
    
    if (result) {
        DBError *dberror = nil;
        if ([datastore sync:&dberror]) {
            return YES;
        } else {
            if (error) *error = [NSError errorWithDomain:[dberror domain] code:[dberror code] userInfo:[dberror userInfo]];
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)syncManagedObjectContextDidSave:(NSNotification *)notification
{
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

#pragma mark - ParseNotification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PRETTY_FUNCTION;
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:[MPTargets targetChannel] forKey:@"channels"];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

#pragma mark - UIApplicationDelegate
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"dbMyPets.sqlite"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
