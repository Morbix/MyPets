//
//  MPLoginViewController.h
//  MyPets
//
//  Created by Henrique Morbin on 26/04/15.
//  Copyright (c) 2015 Henrique Morbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface MPLoginViewController : UIViewController

+ (BOOL)shouldAuthenticate;
+ (void)presentLoginController;
+ (UIViewController *)getViewController;
+ (void)countCurrentUserWithSave:(BOOL)shouldSave;

@end
