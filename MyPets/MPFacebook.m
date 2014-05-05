//
//  SUPFacebook.m
//  SUP Places
//
//  Created by HP Developer on 01/05/14.
//  Copyright (c) 2014 Morbix. All rights reserved.
//

#import "MPFacebook.h"

@implementation MPFacebook
+ (id)shared
{
    static MPFacebook *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPFacebook new];
    });
    return manager;
}

- (BOOL)checkLogin
{
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        return TRUE;
    }else{
        [PFUser logOut];
        return FALSE;
    }
}

- (void)logoff
{
    [PFUser logOut];
}

- (BFTask *)taskLoginFacebook
{
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {

        if (!user) {
            if (!error) {
                [task setError:[NSError errorWithDomain:@"br.com.morbix" code:1 userInfo:nil]];
            } else {
                [task setError:error];
            }
        } else {
            FBRequest *request = [FBRequest requestForMe];
            
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    [task setError:error];
                }else{
                    NSDictionary *userData = (NSDictionary *)result;
                    
                    [[PFUser currentUser] setValue:[userData valueForKey:@"id"] forKey:@"facebookId"];
                    [[PFUser currentUser] setValue:[userData valueForKey:@"name"] forKey:@"facebookName"];
                    [[PFUser currentUser] setValue:[[userData valueForKey:@"location"] valueForKey:@"name"] forKey:@"facebookLocation"];
                    [[PFUser currentUser] setValue:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=1&width=100&height=100&type=normal&return_ssl_resources=1", [userData valueForKey:@"id"]] forKey:@"facebookPhoto"];
                    PFACL *acl = [PFACL ACL];
                    [acl setPublicReadAccess:YES];
                    [acl setPublicWriteAccess:NO];
                    [acl setWriteAccess:YES forUser:[PFUser currentUser]];
                    [[PFUser currentUser] setACL:acl];

                    
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            [task setError:error];
                        }else{
                            [task setResult:[PFUser currentUser]];
                        }
                    }];
                    
                }
            }];
        }
    }];
    
    return task.task;
}


@end
