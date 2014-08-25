//
//  MPPesosViewController.m
//  MyPets
//
//  Created by HP Developer on 12/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPPesosViewController.h"
#import "MPCoreDataService.h"
#import "MPLibrary.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "MPAds.h"
#import <iAd/iAd.h>

@interface MPPesosViewController ()
{
    MPAds *ads;
}

@end

@implementation MPPesosViewController

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

    self.title = NSLS(@"Controle de Peso");
    self.navigationItem.title = self.title;
    
    if ([MPTargets targetAds]) {
        //self.canDisplayBannerAds = YES;
        ads = [[MPAds alloc] initWithScrollView:self.tableView viewController:self admobID:@"ca-app-pub-8687233994493144/7708375167"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    ((MPCoreDataService *)[MPCoreDataService shared]).pesoSelected = nil;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Pesos Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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
    
    Peso *peso = [[MPCoreDataService shared] newPesoToAnimal:animal];
    
    [[MPCoreDataService shared] setPesoSelected:peso];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Adicionar"     // Event category (required)
                                                          action:@"Novo Peso"  // Event action (required)
                                                           label:@"Novo Peso"          // Event label
                                                           value:[NSNumber numberWithInt:animal.cArrayPesos.count]] build]];
    
    [self performSegueWithIdentifier:@"pesoEditViewController" sender:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    return [animal cArrayPesos].count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLS(@"Data e Peso");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    NSMutableArray *arrayPesos = [NSMutableArray arrayWithArray:[[animal cArrayPesos] allObjects]];
    [MPLibrary sortMutableArray:&arrayPesos withAttribute:@"cData" andAscending:NO];
    Peso *peso = [arrayPesos objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
    
    
    cell.textLabel.text = [MPLibrary date:peso.cData
                                 toFormat:NSLS(@"dd.MM.yyyy")];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", peso.cPeso ? peso.cPeso.floatValue : 0.0f];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    NSMutableArray *arrayPesos = [NSMutableArray arrayWithArray:[[animal cArrayPesos] allObjects]];
    [MPLibrary sortMutableArray:&arrayPesos withAttribute:@"cData" andAscending:NO];
    Peso *peso = [arrayPesos objectAtIndex:indexPath.row];
    
    [[MPCoreDataService shared] setPesoSelected:peso];
    
    [self performSegueWithIdentifier:@"pesoEditViewController" sender:nil];
}

@end
