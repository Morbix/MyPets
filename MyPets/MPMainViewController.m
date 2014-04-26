//
//  MPMainViewController.m
//  MyPets
//
//  Created by Henrique Morbin on 25/10/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPMainViewController.h"
#import "MPLibrary.h"
#import "MPCellMainPet.h"
#import "MPCoreDataService.h"
#import "Animal.h"
#import "MPAnimations.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "PKSyncManager.h"
#import "Appirater.h"
#import "LKBadgeView.h"
#import "UIFlatColor.h"
#import "MPAds.h"
#import <iAd/iAd.h>
#import "UIImageView+WebCache.h"
#import "MPDropboxNotification.h"
#import "MPAppDelegate.h"

#define DropboxAppKey @"tnmjxymp32xgs8y"
#define DropboxAppSecret @"czkt8b3dhrcj30b"


@interface MPMainViewController ()
{
    NSArray *arrayPets;
    BOOL CALLBACK_LOCAL;
    int DIV;
    MPAds *ads;
    BOOL ADS_ADDED;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation MPMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
//
    //Antipulgas
    //Albuns
    //Sync com facebook
    //Histórico do pet
//#warning Pendencias
    //2.1.2
    //Ok - Clicar na foto do pet e mostrar fullscrenn + tracking analytics
    //Ok - Delay na tela principal para tentar parar de dar crash
    //2.1.1
    //Ok - Bug da data de nascimento futura
    //Ok - Bug do formato americano
    //Ok - Status do Dropbox com notificações visuais
    //Ok - Verificar track do erro no dropbox
    //Ok - Corrigir link do Rate, Appirater atualizado
    //Ok - Implementar Ads do FelipeOliveira, checa iAd else AdMob
    //###Alta
    //###Média
    //- Versão iPad
    //- Formato de Review do Felipe Oliveira
    //- Fotos das Vacinas com overlay, ou ver foto inteira, ou reposicionar
    //- Sync iCloud
    //- Adicionar outras linguagens (Espanho, Frances, Italiano, Alemão)
    //- Sistema de Ajuda pelo app inteiro
    //- Otimização no CoreData transferindo arquivos de dados para outras entidades
    //###Baixa
    //- algoritmo para sincronizar os alarmes: status nulo(não analisado), 1(sem lembrete), 2(com lembrete)(atenção ao implementar)
    //- Cadastro de Veterinárias
    //- Possibilidade de adicionar PDFs
    //- Possibilidade de adicionar eventos gerais para os apps
    //- Tracking de passeios (MyWay)
    //- Lembretes com recorrência
    //- Lembrete Geral de Vacina!
    //- Cadastro do Cio das Fêmeas
    //- Anexar o Pedigree em PDF
    //- Contatos dos veterinários e veterinárias 24hs
    //- Tela dos próximos eventos
    //- Instapets, Petsgram (trazer mais interações)
    //- Possibilidade de Selecionar formato de Grid ou Lista na tela Principal
    //- Possibilidade de Exportar os dados como um Relatório
    //- Criar sistema de compartilhamento do pet com outros usuários através de um arquivo
    //- Controle Financeiro com os gastos com o Cão
    //- Cálculo de Ração de acordo com o peso

    //2.1.0
    //---Publicacao
    //---Desenvolvimento
    //---Oks
    //Ok - Prints da app stora melhor com gatos
    //Ok - Melhor descricao com reviews, mídia e posicoes
    //Ok - Free e Pago -ATENCAO, tem que duplicar appirater, remover ads, analytics
    //Ok - Ativar iAds apenas no FREE
    //Ok - Setar o Parse para o mesmo nos dois
    //Ok - Inscrever usuario em canais distintos
    //Nada - Teste quando atualizar dropbox o q fazer com os pets sendo atualizados
    //Ok - PageViewTrack nos viewDidAppear
    //Ok - Analytics Track - Dropbox connect e desconnect
    //Ok - Analytics Track - e pageview nas configuracoes (todos os abouts) e lembretes
    //Ok - Criar um track ou PageView também para os status do SKStore Clicou e Carregou
    //Ok - Tela de Configuração com link para app pago para tirar propagandas
    //Ok - About Me (versao, novidades, pagina do face, mais apps, email de contato)
    //Ok - Alterar imagem do clock
    //Ok - Badge na collection do numero de upcoming
    //Ok - Lembretes Programados
    //Ok - Ordem por nome
    //Ok - redimensionar fotos ao salvar
    //Ok - Tradução da tela configuracoes
    //Ok - Diminuicão do tamanho do banco interno
    //Ok - Foto de vermífugo padrao
    //Ok - Correção de bug do Evento Lembretes
    //Ok - Melhorar sombra
    //Ok - Evento significante ao add pet Appirater
    //Ok - Dropbox
    //Ok - iAds
    //Ok - FIX - nao salvar foto padrao nas vacinas e vermifugos
    //Ok - FIX - limpar sem animal
    //Ok - redimensionar fotos na entrada
    //Ok - Peso - arrays e upcomings
    //Ok - Gráfico
    //Ok - Analytics Track - Peso
    
    //2.0
    //Ok - Ads
    //Ok - Parse Notification
    //Ok - GoogleAnalytics
    //Ok - AppIRater
    
    
    
    //Later
    //Exportar
    //Informacoes Adicionais vinda de parceiros
    //Add Frances, Italiano, Espanhol
    
    //Events
    //Ok - Telas
    //Ok - Add com total de itnes
    //Ok - Delecoes 
    //Ok - Fotos
    //Ok - Lembretes
    //Ok - Dropbox connect e desconnect
    //Peso
    //Ok - Event track e pageview nas configuracoes e lembretes
//warning Pendencias
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title                 = NSLS(@"Meus Pets");
    self.navigationItem.title  = self.title;
    
    
    
    //[self.collection setBackgroundColor:[UIColor clearColor]];
    [self.collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell1"];
    [self.collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell2"];
    [self.collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell3"];
    [self.collection setAllowsSelection:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callbackPetsCompleted:) name:MTPSNotificationPets object:nil];

    arrayPets = [NSArray new];
    
    DIV = 1;
    CALLBACK_LOCAL = FALSE;
    ADS_ADDED = FALSE;
    
    [self.collection setContentInset:UIEdgeInsetsMake(64.0f, 0, 0, 0)];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(delayToLoad) withObject:nil afterDelay:2.0f];
    
    ((MPCoreDataService *)[MPCoreDataService shared]).animalSelected = nil;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Main Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)delayToLoad
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MPDropboxNotification shared];
        
        DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:DropboxAppKey secret:DropboxAppSecret];
        [DBAccountManager setSharedManager:accountManager];
        
        if ([accountManager linkedAccount]) {
            [(MPAppDelegate *)[[UIApplication sharedApplication] delegate] setSyncEnabled:YES];
        }
    });
    
    
    if ([MPTargets targetAds] && !ADS_ADDED) {
        ADS_ADDED = TRUE;
        self.canDisplayBannerAds = YES;
        ads = [[MPAds alloc] initWithScrollView:self.collection viewController:self admobID:@"ca-app-pub-8687233994493144/1806932365"];
    }
    
    [self.spinner stopAnimating];
    [[MPCoreDataService shared] loadAllPets];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)barButtonRightTouched:(id)sender
{
    [[MPCoreDataService shared] setAnimalSelected:[[MPCoreDataService shared] newAnimal]];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Adicionar"     // Event category (required)
                                                          action:@"Novo Pet"  // Event action (required)
                                                           label:@"Novo Pet"          // Event label
                                                           value:[NSNumber numberWithInteger:[[MPCoreDataService shared] arrayPets].count]] build]];
    
    [Appirater userDidSignificantEvent:YES];
    
    [self performSegueWithIdentifier:@"petViewController" sender:nil];
}

- (IBAction)barButtonLeftTouched:(id)sender
{
    [self performSegueWithIdentifier:@"configuracaoViewController" sender:nil];
    
}

#pragma mark - Métodos
- (void)configurarBadge:(LKBadgeView *)badge
{
    [badge setBadgeColor:[UIColor colorWithRed:255.0f/255.0f green:202.0f/255.0f blue:80.0f/255.0f alpha:1.0f]];
    [badge setShadowColor:[UIFlatColor blueColor]];
    [badge setHorizontalAlignment:LKBadgeViewHorizontalAlignmentCenter];
    [badge setWidthMode:LKBadgeViewWidthModeStandard];
    [badge setHeightMode:LKBadgeViewHeightModeStandard];
    [badge setFont:[UIFont systemFontOfSize:12.0f]];
    
}

#pragma mark - UICollectionView
#pragma mark  UICollectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    //int count = [[[MPCoreDataService shared] arrayPets] count];
    int count = (int)[arrayPets count];
    
    if (count <= 2) {
        DIV = 1;
    }else if (count <= 6){
        DIV = 2;
    }else{
        DIV = 3;
    }
    
    return count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"cell%d",DIV] forIndexPath:indexPath];
    
    MPCellMainPet *cellView = (MPCellMainPet *)[cell viewWithTag:10];
    LKBadgeView *badge = (LKBadgeView *)[cell viewWithTag:20];
    if (!cellView) {
        cellView = [[MPCellMainPet alloc] initWithDiv:DIV andWidth:self.collection.frame.size.width];
        [cellView setTag:10];
        [cell addSubview:cellView];
    }
    
    if (!badge) {
        CGRect badgeRect;
        switch (DIV) {
            case 1:
                badgeRect = CGRectMake(cell.frame.size.width-60, -4, 60, 60);
                break;
            case 2:
                badgeRect = CGRectMake(cell.frame.size.width-40, -2, 36, 36);
                break;
            case 3:
                badgeRect = CGRectMake(cell.frame.size.width-32, -6, 30, 30);
                break;
                
            default:
                badgeRect = CGRectZero;
                break;
        }
        badge = [[LKBadgeView alloc] initWithFrame:badgeRect];
        [badge setTag:20];
        [self configurarBadge:badge];
        [cell addSubview:badge];
    }
    
    
    //Animal *animal = [[[MPCoreDataService shared] arrayPets] objectAtIndex:indexPath.row];
    Animal *animal = [arrayPets objectAtIndex:indexPath.row];
    [cellView.imagemPet setImage:[animal getFoto]];
    [cellView.labelNome setText:[animal getNome]];
    
    int upcoming = [animal getUpcomingTotal];
    if (upcoming > 0) {
        [badge setText:[NSString stringWithFormat:@"%d", upcoming]];
        [badge setHidden:NO];
    }else{
        [badge setHidden:YES];
    }
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPCellMainPet *cellView = (MPCellMainPet *)[[self.collection cellForItemAtIndexPath:indexPath] viewWithTag:10];
    
    [MPAnimations animationPressDown:cellView];
    
    //Animal *animal = [[[MPCoreDataService shared] arrayPets] objectAtIndex:indexPath.row];
    Animal *animal = [arrayPets objectAtIndex:indexPath.row];
    [[MPCoreDataService shared] setAnimalSelected:animal];
    
    [self performSegueWithIdentifier:@"petViewController" sender:nil];
}


#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float w = self.collection.frame.size.width;
    
    return CGSizeMake((w/DIV), (w/DIV));
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 4);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - MTNotifications
- (void)callbackPetsCompleted:(NSNotification *)notification
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:MTPSNotificationPets object:nil];
    
    CALLBACK_LOCAL = TRUE;
    
    if (notification.userInfo) {
        NSLog(@"error: %s", __PRETTY_FUNCTION__);
    }else{
        if (arrayPets) {
            arrayPets = nil;
            arrayPets = [NSArray arrayWithArray:[[MPCoreDataService shared] arrayPets]];
        }
        [self.collection reloadData];
    }
}
@end
