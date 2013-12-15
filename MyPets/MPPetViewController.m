//
//  MPPetViewController.m
//  MyPets
//
//  Created by HP Developer on 10/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPPetViewController.h"

#import "MPCoreDataService.h"
#import "Animal.h"

@interface MPPetViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@property (weak, nonatomic) IBOutlet UILabel *labelNome;
@property (weak, nonatomic) IBOutlet UILabel *labelDescricao;
@property (weak, nonatomic) IBOutlet UILabel *labelIdade;
@property (weak, nonatomic) IBOutlet UIImageView *imageFoto;
@end

@implementation MPPetViewController

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
    
    self.barButtonRight.title  = NSLS(@"Editar");
}

-(void)viewWillAppear:(BOOL)animated
{
    [self atualizarPagina];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Métodos
- (void)atualizarPagina
{
    if ([[MPCoreDataService shared] animalSelected]) {
        self.title                 = [[[MPCoreDataService shared] animalSelected] getNome];
        self.navigationItem.title  = self.title;
        
        self.labelNome.text      = self.title;
        self.labelDescricao.text = [[[MPCoreDataService shared] animalSelected] getDescricao];
        self.labelIdade.text     = [[[MPCoreDataService shared] animalSelected] getIdade];
        
        self.imageFoto.image = [[[MPCoreDataService shared] animalSelected] getFoto];
    }
}

#pragma mark - IBAction
- (IBAction)barButtonRightTouched:(id)sender
{
    [self performSegueWithIdentifier:@"petEditViewController" sender:nil];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: { return @""; }
            break;
        case 1: { return NSLS(@"Carteiras e Calendários"); }
            break;
        case 2: { return NSLS(@"Próximos Eventos"); }
            break;
    }
    
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"";
}

@end
