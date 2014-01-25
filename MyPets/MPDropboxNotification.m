//
//  MPDropboxNotification.m
//  MyPets
//
//  Created by HP Developer on 25/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPDropboxNotification.h"
#import "PKSyncManager.h"
#import "MPCoreDataService.h"
#import "AJNotificationView.h"

#define kPostponeTime 30

@implementation MPDropboxNotification

+ (id)shared
{
    static MPDropboxNotification *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPDropboxNotification new];
        manager.queue = 0;
        manager.lastSyncingNotification = Nil;
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(dropboxNotification:) name:PKSyncManagerDatastoreStatusDidChangeNotification object:nil];
    });
    
    return manager;
}

- (void)dropboxNotification:(NSNotification *)notification
{
    if (notification.userInfo) {
        [[MPCoreDataService shared] loadAllPets];
        if ([notification.userInfo valueForKey:@"status"]){
            int status = [(NSString *)[notification.userInfo valueForKey:@"status"] intValue];
            if (status == 1) {
                self.queue++;
                [self performSelector:@selector(showSyncCompletedNotification) withObject:Nil afterDelay:kPostponeTime];
            }else if (status > 1) {
                [self showSyncingNotification];
            }
        }
    }
}

- (void)showSyncCompletedNotification
{
    self.queue--;
    if (self.queue > 0) {
        return;
    }
    self.queue = 0;
    
    self.lastSyncingNotification = Nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MTPSNotificationSyncUpdate object:nil];
    [AJNotificationView showNoticeInView:[[[UIApplication sharedApplication] delegate] window]
                                    type:AJNotificationTypeGreen
                                   title:NSLS(@"Sincronizado com sucesso!")
                         linedBackground:AJLinedBackgroundTypeStatic
                               hideAfter:1.2f
                                response:^{
                                    
                                }
     ];
}

- (void)showSyncingNotification
{
    if (self.lastSyncingNotification) {
        if ([self.lastSyncingNotification timeIntervalSinceNow] < (60*5)) {
            return;
        }
    }
    
    self.lastSyncingNotification = [NSDate date];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MTPSNotificationSyncUpdate object:nil];
    [AJNotificationView showNoticeInView:[[[UIApplication sharedApplication] delegate] window]
                                    type:AJNotificationTypeBlue
                                   title:NSLS(@"Sincronizando...")
                         linedBackground:AJLinedBackgroundTypeAnimated
                               hideAfter:1.0f
                                response:^{
                                    //This block is called when user taps in the notification
                                    NSLog(@"Response block");
                                }
     ];
}



@end
