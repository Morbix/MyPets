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
#import "UIImageView+WebCache.h"
#import "MPDropboxNotification.h"
#import "MPAppDelegate.h"
#import "MPMigrationManager.h"

@interface MPMainViewController ()
{
    NSArray *arrayPets;
    BOOL CALLBACK_LOCAL;
    int DIV;
    BOOL ADS_ADDED;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet MXBannerView *bannerView;

@end

@implementation MPMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(delayToLoad) withObject:nil afterDelay:2.0f];
    
    ((MPCoreDataService *)[MPCoreDataService shared]).animalSelected = nil;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Main Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    [self.bannerView requestBanner:kBanner_Main target:self];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[[MPMigrationManager alloc] init] startMigration];
    });
}

- (void)delayToLoad
{
    /*static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MPDropboxNotification shared];
        
        DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:DropboxAppKey secret:DropboxAppSecret];
        [DBAccountManager setSharedManager:accountManager];
        
        if ([accountManager linkedAccount]) {
            [(MPAppDelegate *)[[UIApplication sharedApplication] delegate] setSyncEnabled:YES];
        }
    });*/
    
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
    
    [self abrirTelaPet];
}

- (IBAction)barButtonLeftTouched:(id)sender
{
    if (kIPHONE) {
        [self performSegueWithIdentifier:@"configuracaoViewController" sender:nil];
    }else{
        UIStoryboard *iPhone_Storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]];
        
        UIViewController *tela = [iPhone_Storyboard instantiateViewControllerWithIdentifier:@"configuracaoViewController"];
        
        
        [self.navigationController pushViewController:tela animated:YES];
//        return;
//        UIStoryboard *iPhone_Storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]];
//        
//        UIViewController *tela = [iPhone_Storyboard instantiateViewControllerWithIdentifier:@"configuracaoViewController"];
//        
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tela];
//        
//        UIColor *amarelo = [UIColor colorWithRed:255.0f/255.0f green:202.0f/255.0f blue:80.0f/255.0f alpha:1.0f];
//        [nav.navigationBar setTintColor:[UIColor whiteColor]];
//         [nav setModalPresentationStyle:UIModalPresentationFormSheet];
//        [nav.navigationBar setTranslucent:YES];
//        [nav.navigationBar setBarTintColor:amarelo];
//        [nav.navigationBar setBackgroundColor:amarelo];
//        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
//        [self presentViewController:nav animated:YES completion:nil];
    }
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

- (void)abrirTelaPet
{
    if (kIPHONE) {
        [self performSegueWithIdentifier:@"petViewController" sender:nil];
    }else{
        UIStoryboard *iPhone_Storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]];
        
        UIViewController *tela = [iPhone_Storyboard instantiateViewControllerWithIdentifier:@"petViewController"];
        
        
        [self.navigationController pushViewController:tela animated:YES];
        return;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tela];
        
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - UICollectionView
#pragma mark  UICollectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    //int count = [[[MPCoreDataService shared] arrayPets] count];
    int count = (int)[arrayPets count];
    
    if (kIPHONE) {
        if (count <= 2) {
            DIV = 1;
        }else if (count <= 6){
            DIV = 2;
        }else{
            DIV = 3;
        }
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
    
    [MPAnimations animationPressDown:cellView completion:^(BOOL finished) {
        //Animal *animal = [[[MPCoreDataService shared] arrayPets] objectAtIndex:indexPath.row];
        Animal *animal = [arrayPets objectAtIndex:indexPath.row];
        [[MPCoreDataService shared] setAnimalSelected:animal];
        
        [self abrirTelaPet];
    }];
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
        //NSLog(@"error: %s", __PRETTY_FUNCTION__);
    }else{
        if (arrayPets) {
            arrayPets = nil;
            arrayPets = [NSArray arrayWithArray:[[MPCoreDataService shared] arrayPets]];
        }
        [self.collection reloadData];
    }
}
@end
