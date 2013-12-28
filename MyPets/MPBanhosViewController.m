//
//  MPBanhosViewController.m
//  MyPets
//
//  Created by HP Developer on 17/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPBanhosViewController.h"
#import "MPCoreDataService.h"
#import "Animal.h"
#import "Banho.h"
#import "MPLibrary.h"
#import "MPAnimations.h"
#import "MPLembretes.h"

@interface MPBanhosViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@end

@implementation MPBanhosViewController

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

    self.title = NSLS(@"Agenda Banhos");
    self.navigationItem.title = self.title;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    ((MPCoreDataService *)[MPCoreDataService shared]).banhoSelected = nil;
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
    
    Banho *banho = [[MPCoreDataService shared] newBanhoToAnimal:animal];
    
    [[MPCoreDataService shared] setBanhoSelected:banho];
    
    [self performSegueWithIdentifier:@"banhoEditViewController" sender:nil];
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
        return [animal getNextBanhos].count > 0 ? [animal getNextBanhos].count : 1;
    }else{
        return [animal getPreviousBanhos].count > 0 ? [animal getPreviousBanhos].count : 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    Banho *banho = nil;
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextBanhos].count > 0) {
            banho = [[animal getNextBanhos] objectAtIndex:indexPath.row];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoData" forIndexPath:indexPath];
            [(UILabel *)[cell viewWithTag:10] setText:NSLS(@"Sem Registros")];
        }
    }else{
        if ([animal getPreviousBanhos].count > 0) {
            banho = [[animal getPreviousBanhos] objectAtIndex:indexPath.row];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoData" forIndexPath:indexPath];
            [(UILabel *)[cell viewWithTag:10] setText:NSLS(@"Sem Registros")];
        }
    }
    
    if (banho) {
        if (![[MPLembretes shared] existNotificationFromObject:banho]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
        }
        
        UILabel *labelBanho    = (UILabel *)[cell viewWithTag:10];
        UILabel *labelData        = (UILabel *)[cell viewWithTag:20];
        UILabel *labelLembrete    = (UILabel *)[cell viewWithTag:30];
        
        
        [labelBanho setText:NSLS(@"Banho")];
        
        if (banho.cData) {
            [labelData setText:[MPLibrary date:banho.cData
                                      toFormat:NSLS(@"dd.MM.yyyy hh:mm")]];
        }else{
            [labelData setText:@"-"];
        }
        
        if (labelLembrete) {
            [labelLembrete setText:banho.cLembrete];
        }
        
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLS(@"Próximos Banhos");
    }else{
        return NSLS(@"Banhos");
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    Banho *banho = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextBanhos].count > 0) {
            banho = [[animal getNextBanhos] objectAtIndex:indexPath.row];
        }else{
            banho = nil;
        }
    }else{
        if ([animal getPreviousBanhos].count > 0) {
            banho = [[animal getPreviousBanhos] objectAtIndex:indexPath.row];
        }else{
            banho = nil;
        }
    }
    
    if (banho) {
        if (![[MPLembretes shared] existNotificationFromObject:banho]) {
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
    Banho *banho = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextBanhos].count > 0) {
            banho = [[animal getNextBanhos] objectAtIndex:indexPath.row];
        }
    }else{
        if ([animal getPreviousBanhos].count > 0) {
            banho = [[animal getPreviousBanhos] objectAtIndex:indexPath.row];
        }
    }
    
    if (banho) {
        UIImageView *imageView = (UIImageView *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:10];
        
        [MPAnimations animationPressDown:imageView];
        
        [[MPCoreDataService shared] setBanhoSelected:banho];
        
        [self performSegueWithIdentifier:@"banhoEditViewController" sender:nil];
    }
}


@end
