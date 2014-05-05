//
//  SUPFacebook.h
//  SUP Places
//
//  Created by HP Developer on 01/05/14.
//  Copyright (c) 2014 Morbix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>

@interface MPFacebook : NSObject

+ (id)shared;

- (BOOL)checkLogin;
- (void)logoff;
- (BFTask *)taskLoginFacebook;
@end
