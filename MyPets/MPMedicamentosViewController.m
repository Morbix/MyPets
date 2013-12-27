//
//  MPMedicamentosViewController.m
//  MyPets
//
//  Created by HP Developer on 25/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPMedicamentosViewController.h"
#import "MPCoreDataService.h"
#import "Animal.h"
#import "Banho.h"
#import "MPLibrary.h"
#import "MPAnimations.h"

@interface MPMedicamentosViewController ()

@end

@implementation MPMedicamentosViewController

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

    self.title = NSLS(@"Agenda Medicamentos");
    self.navigationItem.title = self.title;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    ((MPCoreDataService *)[MPCoreDataService shared]).medicamentoSelected = nil;
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
    
    Medicamento *medicamento = [[MPCoreDataService shared] newMedicamentoToAnimal:animal];
    
    [[MPCoreDataService shared] setMedicamentoSelected:medicamento];
    
    [self performSegueWithIdentifier:@"medicamentoEditViewController" sender:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    if (section == 0) {
        return [animal getNextMedicamentos].count > 0 ? [animal getNextMedicamentos].count : 1;
    }else{
        return [animal getPreviousMedicamentos].count > 0 ? [animal getPreviousMedicamentos].count : 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    
    Medicamento *medicamento = nil;
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextMedicamentos].count > 0) {
            medicamento = [[animal getNextMedicamentos] objectAtIndex:indexPath.row];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoData" forIndexPath:indexPath];
            [(UILabel *)[cell viewWithTag:10] setText:NSLS(@"Sem Registros")];
        }
    }else{
        if ([animal getPreviousMedicamentos].count > 0) {
            medicamento = [[animal getPreviousMedicamentos] objectAtIndex:indexPath.row];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoData" forIndexPath:indexPath];
            [(UILabel *)[cell viewWithTag:10] setText:NSLS(@"Sem Registros")];
        }
    }
    
    if (medicamento) {
        if ([medicamento.cLembrete isEqualToString:NSLS(@"Nunca")]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
        }
        
        UILabel *labelMedicamento = (UILabel *)[cell viewWithTag:10];
        UILabel *labelDose        = (UILabel *)[cell viewWithTag:20];
        UILabel *labelData        = (UILabel *)[cell viewWithTag:30];
        UILabel *labelLembrete    = (UILabel *)[cell viewWithTag:40];
        
        
        [labelMedicamento setText:medicamento.cNome];
        [labelDose setText:medicamento.cDose];
        
        if (medicamento.cData) {
            [labelData setText:[MPLibrary date:medicamento.cData
                                      toFormat:NSLS(@"dd.MM.yyyy hh:mm")]];
        }else{
            [labelData setText:@"-"];
        }
        
        if (labelLembrete) {
            [labelLembrete setText:medicamento.cLembrete];
        }
        
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLS(@"Próximos Medicamentos");
    }else{
        return NSLS(@"Medicamentos");
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    Medicamento *medicamento = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextMedicamentos].count > 0) {
            medicamento = [[animal getNextMedicamentos] objectAtIndex:indexPath.row];
        }else{
            medicamento = nil;
        }
    }else{
        if ([animal getPreviousMedicamentos].count > 0) {
            medicamento = [[animal getPreviousMedicamentos] objectAtIndex:indexPath.row];
        }else{
            medicamento = nil;
        }
    }
    
    if (medicamento) {
        if ([medicamento.cLembrete isEqualToString:NSLS(@"Nunca")]) {
            return 60.0f;
        }else{
            return 80.0f;
        }
    }else{
        return 44.0f;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    Medicamento *medicamento = nil;
    
    if (indexPath.section == 0) {
        if ([animal getNextMedicamentos].count > 0) {
            medicamento = [[animal getNextMedicamentos] objectAtIndex:indexPath.row];
        }
    }else{
        if ([animal getPreviousMedicamentos].count > 0) {
            medicamento = [[animal getPreviousMedicamentos] objectAtIndex:indexPath.row];
        }
    }
    
    if (medicamento) {
        UIImageView *imageView = (UIImageView *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:10];
        
        [MPAnimations animationPressDown:imageView];
        
        [[MPCoreDataService shared] setMedicamentoSelected:medicamento];
        
        [self performSegueWithIdentifier:@"medicamentoEditViewController" sender:nil];
    }
}

@end
