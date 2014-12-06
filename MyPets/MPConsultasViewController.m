//
//  MPConsultasViewController.m
//  MyPets
//
//  Created by HP Developer on 17/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPConsultasViewController.h"
#import "MPCoreDataService.h"
#import "Animal.h"
#import "Consulta.h"
#import "MPLibrary.h"
#import "MPAnimations.h"
#import "MPLembretes.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface MPConsultasViewController ()


@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@end

@implementation MPConsultasViewController

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

    self.title = NSLS(@"Agenda Consultas");
    self.navigationItem.title = self.title;
    
    [self createBannerView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    ((MPCoreDataService *)[MPCoreDataService shared]).consultaSelected = nil;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Consultas Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self requestBanner:kBanner_Listagem];
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
    
    Consulta *consulta = [[MPCoreDataService shared] newConsultaToAnimal:animal];
    
    [[MPCoreDataService shared] setConsultaSelected:consulta];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Adicionar"     // Event category (required)
                                                          action:@"Nova Consulta"  // Event action (required)
                                                           label:@"Nova Consulta"          // Event label
                                                           value:[NSNumber numberWithInt:(int)animal.cArrayConsultas.count]] build]];
    
    [self performSegueWithIdentifier:@"consultaEditViewController" sender:nil];
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
        return [animal getNextConsultas].count > 0 ? [animal getNextConsultas].count : 1;
    }else{
        return [animal getPreviousConsultas].count > 0 ? [animal getPreviousConsultas].count : 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    Consulta *consulta = nil;
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextConsultas].count > 0) {
            consulta = [[animal getNextConsultas] objectAtIndex:indexPath.row];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoData" forIndexPath:indexPath];
            [(UILabel *)[cell viewWithTag:10] setText:NSLS(@"Sem Registros")];
        }
    }else{
        if ([animal getPreviousConsultas].count > 0) {
            consulta = [[animal getPreviousConsultas] objectAtIndex:indexPath.row];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoData" forIndexPath:indexPath];
            [(UILabel *)[cell viewWithTag:10] setText:NSLS(@"Sem Registros")];
        }
    }
    
    if (consulta) {
        if (![[MPLembretes shared] existNotificationFromObject:consulta]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
        }
        
        UILabel *labelConsulta    = (UILabel *)[cell viewWithTag:10];
        UILabel *labelData        = (UILabel *)[cell viewWithTag:20];
        UILabel *labelLembrete    = (UILabel *)[cell viewWithTag:30];
        
        
        [labelConsulta setText:NSLS(@"Consulta")];
        
        if (consulta.cData) {
            [labelData setText:[MPLibrary date:consulta.cData
                                          toFormat:NSLS(@"dd.MM.yyyy hh:mm a")]];
        }else{
            [labelData setText:@"-"];
        }
        
        if (labelLembrete) {
            [labelLembrete setText:consulta.cLembrete];
        }
        
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLS(@"Próximas Consultas");
    }else{
        return NSLS(@"Consultas");
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    Consulta *consulta = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextConsultas].count > 0) {
            consulta = [[animal getNextConsultas] objectAtIndex:indexPath.row];
        }else{
            consulta = nil;
        }
    }else{
        if ([animal getPreviousConsultas].count > 0) {
            consulta = [[animal getPreviousConsultas] objectAtIndex:indexPath.row];
        }else{
            consulta = nil;
        }
    }
    
    if (consulta) {
        if (![[MPLembretes shared] existNotificationFromObject:consulta]) {
            return 44.0f;
        }else{
            return 60.0f;
        }
    }else{
        return 44.0f;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    Consulta *consulta = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextConsultas].count > 0) {
            consulta = [[animal getNextConsultas] objectAtIndex:indexPath.row];
        }
    }else{
        if ([animal getPreviousConsultas].count > 0) {
            consulta = [[animal getPreviousConsultas] objectAtIndex:indexPath.row];
        }
    }
    
    if (consulta) {
        UIImageView *imageView = (UIImageView *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:10];
        
        [MPAnimations animationPressDown:imageView];
        
        [[MPCoreDataService shared] setConsultaSelected:consulta];
        
        [self performSegueWithIdentifier:@"consultaEditViewController" sender:nil];
    }
}
@end
