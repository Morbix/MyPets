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
#import "UIFlatColor.h"
#import "LKBadgeView.h"

@interface MPPetViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@property (weak, nonatomic) IBOutlet UILabel *labelNome;
@property (weak, nonatomic) IBOutlet UILabel *labelDescricao;
@property (weak, nonatomic) IBOutlet UILabel *labelIdade;
@property (weak, nonatomic) IBOutlet UIImageView *imageFoto;
@property (weak, nonatomic) IBOutlet UILabel *labelVacinacao;
@property (weak, nonatomic) IBOutlet UILabel *labelVermifugo;
@property (weak, nonatomic) IBOutlet UILabel *labelConsultas;
@property (weak, nonatomic) IBOutlet UILabel *labelBanhos;
@property (weak, nonatomic) IBOutlet LKBadgeView *badgeVacina;
@property (weak, nonatomic) IBOutlet LKBadgeView *badgeVermifugo;
@property (weak, nonatomic) IBOutlet LKBadgeView *badgeConsultas;
@property (weak, nonatomic) IBOutlet LKBadgeView *badgeBanhos;
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
    self.labelVacinacao.text   = NSLS(@"Carteira Vacinação");
    self.labelVermifugo.text   = NSLS(@"Carteira Vermífugo");
    self.labelConsultas.text   = NSLS(@"Agenda Consultas");
    self.labelBanhos.text      = NSLS(@"Agenda Banhos");
    
    
    [self configurarBadge:self.badgeVacina];
    [self configurarBadge:self.badgeVermifugo];
    [self configurarBadge:self.badgeConsultas];
    [self configurarBadge:self.badgeBanhos];
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
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    if (animal) {
        self.title                 = [animal getNome];
        self.navigationItem.title  = self.title;
        
        self.labelNome.text      = self.title;
        self.labelDescricao.text = [animal getDescricao];
        self.labelIdade.text     = [animal getIdade];
        
        self.imageFoto.image = [animal getFoto];
        
        self.badgeVacina.text    = [NSString stringWithFormat:@"%d", [animal getNextVacinas].count];
        self.badgeVermifugo.text = [NSString stringWithFormat:@"%d", [animal getNextVermifugos].count];
        self.badgeConsultas.text = [NSString stringWithFormat:@"%d", [animal getNextConsultas].count];
        self.badgeBanhos.text    = [NSString stringWithFormat:@"%d", [animal getNextBanhos].count];
    }
}

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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: { [self performSegueWithIdentifier:@"vacinasViewController" sender:Nil]; }
                break;
            case 1: { [self performSegueWithIdentifier:@"vermifugosViewController" sender:Nil]; }
                break;
            case 2: { [self performSegueWithIdentifier:@"consultasViewController" sender:Nil]; }
                break;
            case 3: { [self performSegueWithIdentifier:@"banhosViewController" sender:Nil]; }
                break;
        }
    }
}

@end
