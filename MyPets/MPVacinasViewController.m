//
//  MPVacinasViewController.m
//  MyPets
//
//  Created by HP Developer on 17/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPVacinasViewController.h"
#import "MPCoreDataService.h"
#import "Animal.h"
#import "Vacina.h"
#import "Veterinario.h"
#import "MPLibrary.h"
#import "MPAnimations.h"

@interface MPVacinasViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@end

@implementation MPVacinasViewController

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

    self.title = NSLS(@"Carteira Vacinação");
    self.navigationItem.title = self.title;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    ((MPCoreDataService *)[MPCoreDataService shared]).vacinaSelected = nil;
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
    
    Vacina *vacina = [[MPCoreDataService shared] newVacinaToAnimal:animal];
    
    [[MPCoreDataService shared] setVacinaSelected:vacina];
    
    [self performSegueWithIdentifier:@"vacinaEditViewController" sender:nil];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    if (section == 0) {
        return [animal getNextVacinas].count > 0 ? [animal getNextVacinas].count : 1;
    }else{
        return [animal getPreviousVacinas].count > 0 ? [animal getPreviousVacinas].count : 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    Vacina *vacina = nil;
    
    UITableViewCell *cell = nil;

    if (indexPath.section == 0) {
        if ([animal getNextVacinas].count > 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
            vacina = [[animal getNextVacinas] objectAtIndex:indexPath.row];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoData" forIndexPath:indexPath];
            [(UILabel *)[cell viewWithTag:10] setText:NSLS(@"Sem Registros")];
        }
    }else{
        if ([animal getPreviousVacinas].count > 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
            vacina = [[animal getPreviousVacinas] objectAtIndex:indexPath.row];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoData" forIndexPath:indexPath];
            [(UILabel *)[cell viewWithTag:10] setText:NSLS(@"Sem Registros")];
        }
    }
    
    if (vacina) {
        UILabel *labelVeterinario = (UILabel *)[cell viewWithTag:20];
        UILabel *labelData        = (UILabel *)[cell viewWithTag:30];
        UILabel *labelRevacina    = (UILabel *)[cell viewWithTag:40];
        UILabel *valueVeterinario = (UILabel *)[cell viewWithTag:50];
        UILabel *valueData        = (UILabel *)[cell viewWithTag:60];
        UILabel *valueRevacina    = (UILabel *)[cell viewWithTag:70];
        UIImageView *imageViewFoto = (UIImageView *)[cell viewWithTag:10];
        UIImageView *imageViewAlarme = (UIImageView *)[cell viewWithTag:80];
        
        [labelVeterinario setText:NSLS(@"Veterinário")];
        [labelData setText:NSLS(@"Data")];
        [labelRevacina setText:NSLS(@"Revacina")];
        
        [valueVeterinario setText:vacina.cVeterinario];
        [valueData setText:[MPLibrary date:vacina.cDataVacina
                                  toFormat:NSLS(@"dd.MM.yyyy")]];
        [imageViewFoto setImage:[vacina getFoto]];
        
        if (vacina.cData) {
            [valueRevacina setText:[MPLibrary date:vacina.cData
                                      toFormat:NSLS(@"dd.MM.yyyy")]];
            if ([vacina.cLembrete isEqualToString:NSLS(@"Nunca")]) {
                [imageViewAlarme setHidden:YES];
            }else{
                [imageViewAlarme setHidden:NO];
            }
        }else{
            [valueRevacina setText:@""];
            [imageViewAlarme setHidden:YES];
        }
        
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLS(@"Próximas Revacinas");
    }else{
        return NSLS(@"Vacinas");
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    if (indexPath.section == 0) {
        if ([animal getNextVacinas].count > 0) {
            return 160.0f;
        }else{
            return 44.0f;
        }
    }else{
        if ([animal getPreviousVacinas].count > 0) {
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
    Vacina *vacina = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextVacinas].count > 0) {
            vacina = [[animal getNextVacinas] objectAtIndex:indexPath.row];
        }
    }else{
        if ([animal getPreviousVacinas].count > 0) {
            vacina = [[animal getPreviousVacinas] objectAtIndex:indexPath.row];
        }
    }

    if (vacina) {
        UIImageView *imageView = (UIImageView *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:10];
        
        [MPAnimations animationPressDown:imageView];
        
        [[MPCoreDataService shared] setVacinaSelected:vacina];
        
        [self performSegueWithIdentifier:@"vacinaEditViewController" sender:nil];
    }
}

@end
