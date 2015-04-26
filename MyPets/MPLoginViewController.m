//
//  MPLoginViewController.m
//  MyPets
//
//  Created by Henrique Morbin on 26/04/15.
//  Copyright (c) 2015 Henrique Morbin. All rights reserved.
//

#import "MPLoginViewController.h"
#import "MXRoundedButton.h"
#import "MPAppDelegate.h"

@interface MPLoginViewController ()

@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet MXRoundedButton *btnFacebook;
@property (strong, nonatomic) IBOutlet UIButton *btnOffline;
@property (strong, nonatomic) IBOutlet UIImageView *imageSync;
@end

@implementation MPLoginViewController

+ (BOOL)shouldAuthenticate
{
    return (!([PFUser currentUser] && [[PFUser currentUser] isAuthenticated]));
}

+ (void)presentLoginController
{
    UIViewController *presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [presentingViewController presentViewController:[MPLoginViewController getViewController]
                                           animated:YES
                                         completion:nil];
}

+ (UIViewController *)getViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *viewContorller = [storyboard instantiateInitialViewController];
    return viewContorller;
}

+ (void)countCurrentUserWithSave:(BOOL)shouldSave
{
    if ([PFUser currentUser]) {
        [[PFUser currentUser] incrementKey:@"RunCount"];
        if ([PFInstallation currentInstallation]) {
            if ([PFInstallation currentInstallation].deviceToken) {
                [[PFUser currentUser] setObject:[PFInstallation currentInstallation].deviceToken forKey:@"deviceToken"];
            }
            
        }
        
        [[PFUser currentUser] setObject:[[UIDevice currentDevice] name]
                                 forKey:@"deviceName"];
        [[PFUser currentUser] setObject:[[UIDevice currentDevice] systemName]
                                 forKey:@"deviceSystemName"];
        [[PFUser currentUser] setObject:[[UIDevice currentDevice] model]
                                 forKey:@"deviceModel"];
        [[PFUser currentUser] setObject:[[UIDevice currentDevice] systemVersion]
                                 forKey:@"deviceSystemVersion"];
        [[PFUser currentUser] setObject:[[UIDevice currentDevice] localizedModel]
                                 forKey:@"deviceLocalizedModel"];
        
        [[PFUser currentUser] setObject:[MPTargets targetChannel] forKey:@"app"];
        
        if (shouldSave) {
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (MX_DESENV_MODE) {
                    if (error) {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }
            }];
        }
        
        if ([PFInstallation currentInstallation]) {
            if (![[PFInstallation currentInstallation] objectForKey:@"user"]) {
                [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"User"];
                [[PFInstallation currentInstallation] saveInBackground];
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.labelDescription setText:[NSString stringWithFormat:@"%@",
                                    NSLS(@"KEEP YOUR DATA SAFE. \nKEEP YOUR DATA SYNC.")]];
    
    [self.btnFacebook setTitle:[NSString stringWithFormat:@"%@",
                                NSLS(@"Connect with Facebook")] forState:UIControlStateNormal];
    
    [self.btnOffline setTitle:[NSString stringWithFormat:@"%@",
                               NSLS(@"Not now, I want to keep using it without sync.")] forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self checkIfAlreadyAuthenticated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods
- (void)checkIfAlreadyAuthenticated
{
    if ([PFUser currentUser] && [[PFUser currentUser] isAuthenticated]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)updateUIConnecting:(BOOL)connecting
{
    self.btnFacebook.hidden = connecting;
    self.btnOffline.enabled = !connecting;
}

- (void)setUpCurrentUserWithResultData:(id)result
{
    NSDictionary *userData = (NSDictionary *)result;
    
    if (MX_DESENV_MODE) {
        NSLog(@"%@", userData);
    }
    
    if ([userData valueForKey:@"id"]) {
        [[PFUser currentUser] setValue:[userData valueForKey:@"id"] forKey:@"facebookId"];
        [[PFUser currentUser] setValue:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=1&width=100&height=100&type=normal&return_ssl_resources=1", [userData valueForKey:@"id"]] forKey:@"facebookPhoto"];
    }
    
    if ([userData valueForKey:@"name"]) {
        [[PFUser currentUser] setValue:[userData valueForKey:@"name"] forKey:@"facebookName"];
    }
    
    if ([userData valueForKey:@"first_name"]) {
        [[PFUser currentUser] setValue:[userData valueForKey:@"first_name"] forKey:@"facebookFirstName"];
    }
    
    if ([userData valueForKey:@"last_name"]) {
        [[PFUser currentUser] setValue:[userData valueForKey:@"last_name"] forKey:@"facebookLastName"];
    }
    
    if ([userData valueForKey:@"location"]) {
        [[PFUser currentUser] setValue:[[userData valueForKey:@"location"] valueForKey:@"name"] forKey:@"facebookLocation"];
    }
    
    if ([userData valueForKey:@"gender"]) {
        [[PFUser currentUser] setValue:[userData valueForKey:@"gender"] forKey:@"facebookGender"];
    }
    
    if ([userData valueForKey:@"link"]) {
        [[PFUser currentUser] setValue:[userData valueForKey:@"link"] forKey:@"facebookLink"];
    }
    
    if ([userData valueForKey:@"email"]) {
        [[PFUser currentUser] setValue:[userData valueForKey:@"email"] forKey:@"facebookEmail"];
        [[PFUser currentUser] setEmail:[userData valueForKey:@"email"]];
    }
}

- (void)countCurrentUserWithSave:(BOOL)shouldSave
{
    [MPLoginViewController countCurrentUserWithSave:shouldSave];
}

- (void)showFeedbackError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ops"
                                                    message:@"Couldn't connect. Try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)dismissScreen
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions
- (IBAction)btnFacebookTouched:(id)sender
{
    [self updateUIConnecting:YES];
    
    //NSArray *permissions = @[@"user_about_me", @"user_location"];
    NSArray *permissions = @[@"public_profile", @"email", @"user_friends"];

    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions
                                                    block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            if (MX_DESENV_MODE) {
                NSLog(@"%s - %@", __PRETTY_FUNCTION__, error);
            }
            
            [PFUser logOut];
            [self updateUIConnecting:NO];
            [self showFeedbackError];
        } else {
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                          initWithGraphPath:@"me"
                                          parameters:nil
                                          HTTPMethod:@"GET"];
            
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    if (MX_DESENV_MODE) {
                        NSLog(@"%s - %@", __PRETTY_FUNCTION__, error);
                    }
                    
                    [PFUser logOut];
                    [self updateUIConnecting:NO];
                    [self showFeedbackError];
                }else{
                    
                    [self setUpCurrentUserWithResultData:result];
                    [self countCurrentUserWithSave:NO];
                    
                    PFACL *acl = [PFACL ACL];
                    [acl setPublicReadAccess:YES];
                    [acl setPublicWriteAccess:NO];
                    [acl setWriteAccess:YES forUser:[PFUser currentUser]];
                    [[PFUser currentUser] setACL:acl];
                    
                    
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            if (MX_DESENV_MODE) {
                                NSLog(@"%s - %@", __PRETTY_FUNCTION__, error);
                            }
                            
                            [PFUser logOut];
                            [self updateUIConnecting:NO];
                            [self showFeedbackError];
                        }else{
                            self.imageSync.highlighted = YES;
                            [self performSelector:@selector(dismissScreen)
                                       withObject:nil
                                       afterDelay:1.0f];
                        }
                    }];
                }
            }];
        }
    }];
}

- (IBAction)btnOfflineTouched:(id)sender
{
    [self dismissScreen];
}
@end
