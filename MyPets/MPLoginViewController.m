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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

#pragma mark - Actions
- (IBAction)btnFacebookTouched:(id)sender {
}
- (IBAction)btnOfflineTouched:(id)sender {
}
@end
