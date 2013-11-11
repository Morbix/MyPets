//
//  MPAppDelegate.h
//  MyPets
//
//  Created by Henrique Morbin on 23/10/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSNavigationPaneViewController;

@interface MPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) MSNavigationPaneViewController *navigationPaneViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
