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

@interface MPConfigViewController () <SKStoreProductViewControllerDelegate>
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
    self.labelEmail.text      = NSLS(@"Enviar um e-mail");
    self.labelFacebook.text   = NSLS(@"Curtir a nossa página");
    self.labelLembretes.text  = NSLS(@"Mostrar lembretes");
    
    [self.imageIcone.layer setCornerRadius:6];
    [self.imageIcone.layer setMasksToBounds:YES];
    [self configurarBadge:self.badgeLembretes];
    
    self.syncSwitch.enabled = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxStatusUpdateNotification:) name:MTPSNotificationSyncUpdate object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Configuração Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if ([MPTargets targetAds]) {
        //self.canDisplayBannerAds = YES;
        if (!ads) {
            ads = [[MPAds alloc] initWithScrollView:self.tableView viewController:self admobID:@"ca-app-pub-8687233994493144/3138574766"];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!kIPHONE) {
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Ok"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(dismissModalViewControllerAnimated:)];
        [self.navigationItem setLeftBarButtonItem:back];
    }
    
    
    //self.syncSwitch.on = [[DBAccountManager sharedManager] linkedAccount] != nil;
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
    return;
    
    /*DBAccountManager *accountManager = [DBAccountManager sharedManager];
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
    }*/
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
        return NSLS(@"Salve seus dados na nuvem");
    }else if (section == 1){
        return NSLS(@"Contatos e Feedback");
    }else if (section == 2){
        return NSLS(@"Lembretes Programados");
    }else if (section == 3){
        return NSLS(@"Quer remover os anúncios?");
    }
    
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        /*if ([[DBAccountManager sharedManager] linkedAccount] != nil) {
            PKSyncManager *syncManger = [(MPAppDelegate *)[[UIApplication sharedApplication] delegate] syncManager];
            if (syncManger) {
                if (syncManger.datastore.status > 1) { //!= DBDatastoreConnected
                    return NSLS(@"Sincronizando...");
                }else{
                    return NSLS(@"Sincronizado com sucesso!");
                }
            }
        }*/

        return NSLS(@"O Dropbox foi desativado. Estamos preparando uma nova forma para guardar seus dados.");
    }else if (section == 1){
        return NSLS(@"");
    }else if (section == 2){
        return NSLS(@"");
    }else if (section == 3){
        return NSLS(@"");
    }
    
    return @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            //Dropbox
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Links"
                                                                          action:@"Facebook"
                                                                           label:@"Facebook"
                                                                           value:nil] build]];
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
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Links"
                                                                          action:@"Email"
                                                                           label:@"Email"
                                                                           value:nil] build]];
                    NSURL *url = [NSURL URLWithString:kLinkMail];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }
                    break;
                case 2:
                {
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Links"
                                                                          action:@"Rate"
                                                                           label:@"Rate"
                                                                           value:nil] build]];
                    
                    [Appirater rateApp];
                    
                    /*//553815375 - kTargetAppID
                    //422347491 - Morbix
                    //795757886 - MyPets Paid
                    NSDictionary *parameters = [NSDictionary dictionaryWithObject:[MPTargets targetAppID]
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
                        id tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker set:kGAIScreenName
                               value:@"MyPets Free iTunes Screen"];
                        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
                    }];*/
                }
                    break;
                case 3:
                {
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Links"
                                                                          action:@"Morbix"
                                                                           label:@"Morbix"
                                                                           value:nil] build]];
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
                        id tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker set:kGAIScreenName
                               value:@"Morbix iTunes Screen"];
                        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Links"
                                                                  action:@"MyPets Paid"
                                                                   label:@"MyPets Paid"
                                                                   value:nil] build]];
            //553815375 - MyPets
            //422347491 - Morbix
            //795757886 - MyPets Paid
            NSDictionary *parameters = [NSDictionary dictionaryWithObject:@"795757886"
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
                id tracker = [[GAI sharedInstance] defaultTracker];
                [tracker set:kGAIScreenName
                       value:@"MyPets Paid iTunes Screen"];
                [tracker send:[[GAIDictionaryBuilder createAppView] build]];
            }];
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

@end
