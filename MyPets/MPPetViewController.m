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
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "PNChart.h"
#import "PNLineChartData.h"
#import "PNLineChartDataItem.h"
#import "MPLibrary.h"
#import "MPPeso.h"

@interface MPPetViewController () <PNChartDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@property (weak, nonatomic) IBOutlet UILabel *labelNome;
@property (weak, nonatomic) IBOutlet UILabel *labelDescricao;
@property (weak, nonatomic) IBOutlet UILabel *labelIdade;
@property (weak, nonatomic) IBOutlet UIImageView *imageFoto;
@property (weak, nonatomic) IBOutlet UILabel *labelVacinacao;
@property (weak, nonatomic) IBOutlet UILabel *labelVermifugo;
@property (weak, nonatomic) IBOutlet UILabel *labelConsultas;
@property (weak, nonatomic) IBOutlet UILabel *labelBanhos;
@property (weak, nonatomic) IBOutlet UILabel *labelMedicamentos;
@property (weak, nonatomic) IBOutlet LKBadgeView *badgeVacina;
@property (weak, nonatomic) IBOutlet LKBadgeView *badgeVermifugo;
@property (weak, nonatomic) IBOutlet LKBadgeView *badgeConsultas;
@property (weak, nonatomic) IBOutlet LKBadgeView *badgeBanhos;
@property (weak, nonatomic) IBOutlet LKBadgeView *badgeMedicamentos;
@property (weak, nonatomic) IBOutlet UIView *bannerSpace;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollPeso;
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
    
    self.barButtonRight.title   = NSLS(@"Editar");
    self.labelVacinacao.text    = NSLS(@"Carteira Vacinação");
    self.labelVermifugo.text    = NSLS(@"Carteira Vermífugo");
    self.labelConsultas.text    = NSLS(@"Agenda Consultas");
    self.labelBanhos.text       = NSLS(@"Agenda Banhos");
    self.labelMedicamentos.text = NSLS(@"Agenda Medicamentos");
    
    
    [self configurarBadge:self.badgeVacina];
    [self configurarBadge:self.badgeVermifugo];
    [self configurarBadge:self.badgeConsultas];
    [self configurarBadge:self.badgeBanhos];
    [self configurarBadge:self.badgeMedicamentos];
}

-(void)viewDidAppear:(BOOL)animated
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([MPTargets targetAds]) {
            [self loadBanner];
        }
    });
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Pet Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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
        self.badgeMedicamentos.text    = [NSString stringWithFormat:@"%d", [animal getNextMedicamentos].count];
        
        [self atualizarGrafico];
    }
}

- (void)atualizarGrafico
{
    for (UIView *view in self.scrollPeso.subviews) {
        [view removeFromSuperview];
    }
    
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, self.scrollPeso.frame.size.width, self.scrollPeso.frame.size.height)];
    [lineChart setBackgroundColor:[UIColor clearColor]];
    
    
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    NSMutableArray *arrayPesos = [NSMutableArray new];
    for (Peso *peso in [[animal cArrayPesos] allObjects]) {
        if (peso.cData && peso.cPeso) {
            MPPeso *mpPeso = [MPPeso new];
            mpPeso.data = peso.cData;
            mpPeso.valor = peso.cPeso;
            mpPeso.dia = [MPLibrary date:peso.cData toFormat:@"d"];
            mpPeso.mes = [MPLibrary date:peso.cData toFormat:@"M"];
            mpPeso.ano = [MPLibrary date:peso.cData toFormat:@"yy"];
            
            [arrayPesos addObject:mpPeso];            
        }
    }
    [MPLibrary sortMutableArray:&arrayPesos withAttribute:@"data" andAscending:YES];
    while (arrayPesos.count > 20) {
        [arrayPesos removeObjectAtIndex:0];
    }
    while (arrayPesos.count < 6) {
        MPPeso *mpPeso = [MPPeso new];
        mpPeso.valor = @0.0;
        mpPeso.dia = @"0";
        mpPeso.mes = @"0";
        mpPeso.ano = @"0";
        [arrayPesos insertObject:mpPeso atIndex:0];
    }
    
    [lineChart setXLabels1:[arrayPesos mutableArrayValueForKey:@"dia"] andXLabels2:[arrayPesos mutableArrayValueForKey:@"mes"] andXLabels3:[arrayPesos mutableArrayValueForKey:@"ano"]];
    NSArray * data01Array = [arrayPesos mutableArrayValueForKey:@"valor"];
    
    
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = PNFreshGreen;
    data01.itemCount = lineChart.xLabels1.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [[data01Array objectAtIndex:index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    lineChart.chartData = @[data01];
    [lineChart strokeChart];
    
    lineChart.delegate = self;
    
    [self.scrollPeso addSubview:lineChart];
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

- (void)loadBanner
{
    //self.view.frame.size.height-bannerView_.frame.size.height;
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    [bannerView_ setFrame:CGRectMake(0, 0, bannerView_.frame.size.width, bannerView_.frame.size.height)];
    
    bannerView_.adUnitID = @"ca-app-pub-8687233994493144/9330199164";
    
    
    bannerView_.rootViewController = self;
    [self.bannerSpace addSubview:bannerView_];
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ @"d739ce5a07568c089d5498568147e06a", @"7229798c8732c56f536549c0f153d45f", GAD_SIMULATOR_ID];
    request.testing = NO;
    [bannerView_ loadRequest: request];
}

#pragma mark - IBAction
- (IBAction)barButtonRightTouched:(id)sender
{
    [self performSegueWithIdentifier:@"petEditViewController" sender:nil];
}

#pragma mark - GADBannerDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    UIEdgeInsets edge =  UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, bannerView_.frame.size.height, self.tableView.scrollIndicatorInsets.right);
    [self.tableView setScrollIndicatorInsets:edge];
    [self.tableView setContentInset:edge];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: { return @""; }
            break;
        case 1: { return NSLS(@"Carteiras e Calendários"); }
            break;
        case 2: { return NSLS(@"Controle de Peso"); }
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
            case 4: { [self performSegueWithIdentifier:@"medicamentosViewController" sender:Nil]; }
                break;
        }
    }else if (indexPath.section == 2){
        [self performSegueWithIdentifier:@"pesosViewController" sender:nil];
    }
}

#pragma mark - PNChartDelegate
-(void)userClickedOnLineKeyPoint:(CGPoint)point lineIndex:(NSInteger)lineIndex andPointIndex:(NSInteger)pointIndex
{
    
}

-(void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex
{
    
}
@end
