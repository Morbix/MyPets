//
//  MPVermifugosViewController.m
//  MyPets
//
//  Created by HP Developer on 17/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPVermifugosViewController.h"
#import "MPCoreDataService.h"
#import "Animal.h"
#import "Vermifugo.h"
#import "Veterinario.h"
#import "MPLibrary.h"
#import "MPAnimations.h"
#import "MPLembretes.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "MPAds.h"
#import <iAd/iAd.h>

@interface MPVermifugosViewController ()
{
    MPAds *ads;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@end

@implementation MPVermifugosViewController

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
    self.title = NSLS(@"Carteira Vermífugo");
    self.navigationItem.title = self.title;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    ((MPCoreDataService *)[MPCoreDataService shared]).vermifugoSelected = nil;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Vermífugos Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if ([MPTargets targetAds]) {
        ads = nil;
        ads = [[MPAds alloc] initWithScrollView:self.tableView viewController:self admobID:kBanner_Listagem];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)barButtonRightTouched:(id)sender
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    Vermifugo *vermifugo = [[MPCoreDataService shared] newVermifugoToAnimal:animal];
    
    [[MPCoreDataService shared] setVermifugoSelected:vermifugo];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Adicionar"     // Event category (required)
                                                          action:@"Novo Vermífugo"  // Event action (required)
                                                           label:@"Novo Vermífugo"          // Event label
                                                           value:[NSNumber numberWithInt:animal.cArrayVermifugos.count]] build]];
    
    [self performSegueWithIdentifier:@"vermifugoEditViewController" sender:nil];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    if (section == 0) {
        return [animal getNextVermifugos].count > 0 ? [animal getNextVermifugos].count : 1;
    }else{
        return [animal getPreviousVermifugos].count > 0 ? [animal getPreviousVermifugos].count : 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    Vermifugo *vermifugo = nil;
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextVermifugos].count > 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
            vermifugo = [[animal getNextVermifugos] objectAtIndex:indexPath.row];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoData" forIndexPath:indexPath];
            [(UILabel *)[cell viewWithTag:10] setText:NSLS(@"Sem Registros")];
        }
    }else{
        if ([animal getPreviousVermifugos].count > 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
            vermifugo = [[animal getPreviousVermifugos] objectAtIndex:indexPath.row];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoData" forIndexPath:indexPath];
            [(UILabel *)[cell viewWithTag:10] setText:NSLS(@"Sem Registros")];
        }
    }
    
    if (vermifugo) {
        UILabel *labelDose        = (UILabel *)[cell viewWithTag:20];
        UILabel *labelData        = (UILabel *)[cell viewWithTag:30];
        UILabel *labelReforco     = (UILabel *)[cell viewWithTag:40];
        UILabel *valueDose        = (UILabel *)[cell viewWithTag:50];
        UILabel *valueData        = (UILabel *)[cell viewWithTag:60];
        UILabel *valueReforco     = (UILabel *)[cell viewWithTag:70];
        UIImageView *imageViewFoto = (UIImageView *)[cell viewWithTag:10];
        UIImageView *imageViewAlarme = (UIImageView *)[cell viewWithTag:80];
        
        [labelDose setText:NSLS(@"Dose")];
        [labelData setText:NSLS(@"Data")];
        [labelReforco setText:NSLS(@"Reforço")];

        [valueDose setText:vermifugo.cDose];
        [valueData setText:[MPLibrary date:vermifugo.cDataVacina
                                  toFormat:NSLS(@"dd.MM.yyyy")]];
        [imageViewFoto setImage:[vermifugo getFoto]];
        
        if (vermifugo.cData) {
            [valueReforco setText:[MPLibrary date:vermifugo.cData
                                          toFormat:NSLS(@"dd.MM.yyyy")]];
            if (![[MPLembretes shared] existNotificationFromObject:vermifugo]) {
                [imageViewAlarme setHidden:YES];
            }else{
                [imageViewAlarme setHidden:NO];
            }
        }else{
            [valueReforco setText:@""];
            [imageViewAlarme setHidden:YES];
        }
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLS(@"Próximos Reforços");
    }else{
        return NSLS(@"Vermífugos");
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    if (indexPath.section == 0) {
        if ([animal getNextVermifugos].count > 0) {
            return 160.0f;
        }else{
            return 44.0f;
        }
    }else{
        if ([animal getPreviousVermifugos].count > 0) {
            return 160.0f;
        }else{
            return 44.0f;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    Vermifugo *vermifugo = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextVermifugos].count > 0) {
            vermifugo = [[animal getNextVermifugos] objectAtIndex:indexPath.row];
        }
    }else{
        if ([animal getPreviousVermifugos].count > 0) {
            vermifugo = [[animal getPreviousVermifugos] objectAtIndex:indexPath.row];
        }
    }
    
    if (vermifugo) {
        UIImageView *imageView = (UIImageView *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:10];
        
        [MPAnimations animationPressDown:imageView];
        
        [[MPCoreDataService shared] setVermifugoSelected:vermifugo];
        
        [self performSegueWithIdentifier:@"vermifugoEditViewController" sender:nil];
    }
}

@end
