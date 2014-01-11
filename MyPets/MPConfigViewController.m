//
//  MPConfigViewController.m
//  MyPets
//
//  Created by HP Developer on 08/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPConfigViewController.h"
#import <Dropbox/Dropbox.h>
#import "MPAppDelegate.h"
#import "LKBadgeView.h"
#import "UIFlatColor.h"
#import "MPLembretes.h"
#import <StoreKit/StoreKit.h>
#import <StoreKit/StoreKitDefines.h>

@interface MPConfigViewController () <SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *syncSwitch;
@property (weak, nonatomic) IBOutlet UILabel *labelLembretes;
@property (weak, nonatomic) IBOutlet LKBadgeView *badgeLembretes;
@property (weak, nonatomic) IBOutlet UILabel *labelFacebook;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelAvaliar;
@property (weak, nonatomic) IBOutlet UILabel *labelOutrosApps;
@end

@implementation MPConfigViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLS(@"Configuração");
    self.navigationItem.title = self.title;
    
    self.labelOutrosApps.text = NSLS(@"Conhecer nossos outros apps");
    self.labelAvaliar.text = NSLS(@"Avaliar o MyPets");
    self.labelEmail.text = NSLS(@"Enviar um e-mail");
    self.labelFacebook.text = NSLS(@"Curtir a nossa página");
    self.labelLembretes.text = NSLS(@"Mostrar lembretes");
    [self configurarBadge:self.badgeLembretes];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.syncSwitch.on = [[DBAccountManager sharedManager] linkedAccount] != nil;
    [self.badgeLembretes setText:[NSString stringWithFormat:@"%d", [MPLembretes getCount]]];
}

#pragma mark - Métodos
- (void)configurarBadge:(LKBadgeView *)badge
{
    [badge setBadgeColor:[UIFlatColor clearColor]];
    [badge setBackgroundColor:[UIFlatColor clearColor]];
    [badge setOutline:YES];
    [badge setHorizontalAlignment:LKBadgeViewHorizontalAlignmentCenter];
    [badge setWidthMode:LKBadgeViewWidthModeStandard];
    [badge setHeightMode:LKBadgeViewHeightModeStandard];
    [badge setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [badge setTextColor:[UIColor whiteColor]];
}

#pragma mark - IBActions
- (IBAction)toggleSyncAction:(id)sender
{
    DBAccountManager *accountManager = [DBAccountManager sharedManager];
    DBAccount *account = [accountManager linkedAccount];
    
    if ([sender isOn]) {
        if (!account) {
            [accountManager addObserver:self block:^(DBAccount *account) {
                if ([account isLinked]) {
                    MPAppDelegate *appDelegate = (MPAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate setSyncEnabled:YES];
                }
            }];
            
            [[DBAccountManager sharedManager] linkFromController:self];
        }
    } else {
        MPAppDelegate *appDelegate = (MPAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setSyncEnabled:NO];
        [account unlink];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 4;
            break;
            
        default:
            break;
    }
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLS(@"Salve seus dados na nuvem");
    }else if (section == 2){
        return NSLS(@"Contatos e Feedback");
    }
    
    return @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"lembretesViewController" sender:nil];
        }
    }else if (indexPath.section == 2){
        switch (indexPath.row) {
            case 0:
            {
                NSURL *url = [NSURL URLWithString:kLinkFacebook];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
                break;
            case 1:
            {
                NSURL *url = [NSURL URLWithString:kLinkMail];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
                break;
            case 2:
            {
                //553815375 - MyPets
                //422347491 - Morbix
                NSDictionary *parameters = [NSDictionary dictionaryWithObject:@"553815375"
                                                                       forKey:SKStoreProductParameterITunesItemIdentifier];
                
                SKStoreProductViewController *tela = [[SKStoreProductViewController alloc] init];
                [tela setDelegate:self];
                [tela loadProductWithParameters:parameters
                                completionBlock:^(BOOL result, NSError *error) {
                    if (error) {
                        NSLog(@"%@",error.description);
                    }else{

                    }
                }];
                [self presentViewController:tela animated:YES completion:^{}];
            }
                break;
            case 3:
            {
                //553815375 - MyPets
                //422347491 - Morbix
                NSDictionary *parameters = [NSDictionary dictionaryWithObject:@"422347491"
                                                                       forKey:SKStoreProductParameterITunesItemIdentifier];
                
                SKStoreProductViewController *tela = [[SKStoreProductViewController alloc] init];
                [tela setDelegate:self];
                [tela loadProductWithParameters:parameters
                                completionBlock:^(BOOL result, NSError *error) {
                                    if (error) {
                                        NSLog(@"%@",error.description);
                                    }else{
                                        
                                    }
                                }];
                [self presentViewController:tela animated:YES completion:^{}];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
