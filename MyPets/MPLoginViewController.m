//
//  MPLoginViewController.m
//  MyPets
//
//  Created by Henrique Morbin on 26/04/15.
//  Copyright (c) 2015 Henrique Morbin. All rights reserved.
//

#import "MPLoginViewController.h"
#import "MXRoundedButton.h"

@interface MPLoginViewController ()

@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet MXRoundedButton *btnFacebook;
@property (strong, nonatomic) IBOutlet UIButton *btnOffline;
@end

@implementation MPLoginViewController

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

#pragma mark - Actions
- (IBAction)btnFacebookTouched:(id)sender
{
    [self updateUIConnecting:YES];
    
    
}

- (IBAction)btnOfflineTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
