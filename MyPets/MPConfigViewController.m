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
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "MPDropboxNotification.h"
#import "Appirater.h"
#import "MPAds.h"
#import <iAd/iAd.h>
#import "MPGoogle.h"

@interface MPConfigViewController () <SKStoreProductViewControllerDelegate, UIActionSheetDelegate>
{
    MPAds *ads;
}

@property (weak, nonatomic) IBOutlet UISwitch *syncSwitch;
@property (weak, nonatomic) IBOutlet UILabel *labelLembretes;
@property (weak, nonatomic) IBOutlet LKBadgeView *badgeLembretes;
@property (weak, nonatomic) IBOutlet UILabel *labelFacebook;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelAvaliar;
@property (weak, nonatomic) IBOutlet UILabel *labelOutrosApps;
@property (weak, nonatomic) IBOutlet UIImageView *imageIcone;
@property (weak, nonatomic) IBOutlet UILabel *labelPremium;
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
    self.labelAvaliar.text    = NSLS(@"Avaliar o MyPets");
    self.labelEmail.text      = NSLS(@"Reportar um erro");
    self.labelFacebook.text   = NSLS(@"Curtir a nossa página");
    self.labelLembretes.text  = NSLS(@"Mostrar lembretes");
    self.labelPremium.text    = NSLS(@"Ver os planos do acesso Premium");
    
    [self.imageIcone.layer setCornerRadius:6];
    [self.imageIcone.layer setMasksToBounds:YES];
    [self configurarBadge:self.badgeLembretes];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxStatusUpdateNotification:) name:MTPSNotificationSyncUpdate object:nil];
    
    
    if ([MPTargets targetAds]) {
        self.canDisplayBannerAds = YES;
        ads = [[MPAds alloc] initWithScrollView:self.tableView viewController:self admobID:@"ca-app-pub-8687233994493144/3138574766"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Configuração Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Dropbox"
                                                                          action:@"Conectou"
                                                                           label:@"Conectou"
                                                                           value:nil] build]];
                }
            }];
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Dropbox"
                                                                  action:@"Solicitou"
                                                                   label:@"Solicitou"
                                                                   value:nil] build]];
            
            [[DBAccountManager sharedManager] linkFromController:self];
        }
    } else {
        MPAppDelegate *appDelegate = (MPAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setSyncEnabled:NO];
        [account unlink];
        [self.tableView reloadData];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Dropbox"
                                                              action:@"Desconectou"
                                                               label:@"Desconectou"
                                                               value:nil] build]];
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
    return [MPTargets targetNumberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 4;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
            
        default:
            break;
    }
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLS(@"Acesso Premium");
    }else if (section == 1){
        return NSLS(@"Contatos e Feedback");
    }else if (section == 2){
        return NSLS(@"Lembretes Programados");
    }else if (section == 3){
        return NSLS(@"Salve seus dados na nuvem");
    }
    
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLS(@"Seja um usuário premium e cadastre quantos pets você precisar. Em breve teremos backup dos dados na nuvem, sincronismo com os outros dispositivos, acesso web e muito mais.");
    }else if (section == 1){
        return NSLS(@"");
    }else if (section == 2){
        return NSLS(@"");
    }else if (section == 3){
        return NSLS(@"O recurso do Dropbox foi desativado, pois não estávamos tendo uma boa experiência com o serviço. Estamos preparando uma nova forma de você salvar os dados na nuvem e poder sincronizar com seus outros dispositivos.");
    }
    
    return @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            [[MPGoogle shared] sendEventWithCategory:@"Links"
                                              action:@"Planos"
                                               label:@"Planos"];
            
            [self performSegueWithIdentifier:@"iapViewController" sender:nil];
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    [[MPGoogle shared] sendEventWithCategory:@"Links"
                                                      action:@"Facebook"
                                                       label:@"Facebook"];

                    NSURL *url = [NSURL URLWithString:kLinkFacebook];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }else{
                        NSURL *url = [NSURL URLWithString:kLinkFacebook2];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }
                }
                    break;
                case 1:
                {
                    [[MPGoogle shared] sendEventWithCategory:@"Links"
                                                      action:@"Email"
                                                       label:@"Email"];
                    
                    NSURL *url = [NSURL URLWithString:kLinkMail];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }
                    break;
                case 2:
                {
                    [[MPGoogle shared] sendEventWithCategory:@"Links"
                                                      action:@"Rate"
                                                       label:@"Rate"];
                    
                    [Appirater rateApp];
                }
                    break;
                case 3:
                {
                    [[MPGoogle shared] sendEventWithCategory:@"Links"
                                                      action:@"Morbix"
                                                       label:@"Morbix"];
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
                    [self presentViewController:tela animated:YES completion:^{
                        [[MPGoogle shared] sendTelaWithName:@"Morbix iTunes Screen"];
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"lembretesViewController" sender:nil];
            }
        }
            break;
        case 3:
        {
            [[[UIAlertView alloc] initWithTitle:@"Dropbox" message:NSLS(@"O recurso do Dropbox foi desativado, pois não estávamos tendo uma boa experiência com o serviço. Estamos preparando uma nova forma de você salvar os dados na nuvem e poder sincronizar com seus outros dispositivos.") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - MTPSNotifications
- (void)dropboxStatusUpdateNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

@end
