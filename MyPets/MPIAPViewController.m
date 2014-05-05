//
//  MasterViewController.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "MPIAPViewController.h"
//#import "DetailViewController.h"
#import "MyPetsIAPHelper.h"
#import "MPGoogle.h"
#import "UIViewController+HUD.h"
#import "MPFacebook.h"

@interface MPIAPViewController () <UIAlertViewDelegate>
{
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
    UIBarButtonItem *barButtonRestore, *barButtonLogin;
}
@end

@implementation MPIAPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
 
    barButtonRestore = [[UIBarButtonItem alloc] initWithTitle:NSLS(@"Restore") style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];
    
    barButtonLogin = [[UIBarButtonItem alloc] initWithTitle:NSLS(@"Sign Out") style:UIBarButtonItemStyleBordered target:self action:@selector(signOutTapped:)];
    
    self.navigationItem.rightBarButtonItems = @[barButtonRestore, barButtonLogin];
}

-(void)signOutTapped:(id)sender
{
    if ([PFUser currentUser].isAuthenticated) {
        [PFUser logOut];
        [self reload];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS(@"Autenticação")
                                    message:NSLS(@"Você precisa se autenticar via Facebook.")
                                   delegate:self
                          cancelButtonTitle:NSLS(@"Ok")
                          otherButtonTitles:NSLS(@"Cancelar"), nil];
        [alert setTag:1];
        [alert show];
    }
    
    //[self.navigationController popViewControllerAnimated:YES];

}

- (void)restoreTapped:(id)sender {

    if ([PFUser currentUser].isAuthenticated) {
        [[MyPetsIAPHelper sharedInstance] restoreCompletedTransactions];
        
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        
        [query getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *object, NSError *error) {
            
            NSDate * serverDate = [[object objectForKey:@"ExpirationDate"] lastObject];
            
            [[NSUserDefaults standardUserDefaults] setObject:serverDate forKey:@"ExpirationDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.tableView reloadData];
            
            NSLog(@"Restore Complete!");
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS(@"Autenticação")
                                                        message:NSLS(@"Você precisa se autenticar via Facebook.")
                                                       delegate:self
                                              cancelButtonTitle:NSLS(@"Ok")
                                              otherButtonTitles:NSLS(@"Cancelar"), nil];
        [alert setTag:2];
        [alert show];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    [self.tableView reloadData];
    
    if ([PFUser currentUser].isAuthenticated) {
        [barButtonLogin setTitle:NSLS(@"Sign Out")];
    } else {
        [barButtonLogin setTitle:NSLS(@"Sign In")];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self reload];
            [self.refreshControl beginRefreshing];
            *stop = YES;
        }
    }];
}

- (void)reload {
    if ([PFUser currentUser].isAuthenticated) {
        [barButtonLogin setTitle:NSLS(@"Sign Out")];
    } else {
        [barButtonLogin setTitle:NSLS(@"Sign In")];
    }
    
    _products = nil;
    [self.tableView reloadData];
    [[MyPetsIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    IAPHelper * helper = [[IAPHelper alloc] init];
    
    SKProduct * product = (SKProduct *) _products[indexPath.row];
    cell.textLabel.text = NSLS(product.localizedTitle);
    [_priceFormatter setLocale:product.priceLocale];
    cell.detailTextLabel.text = [_priceFormatter stringFromNumber:product.price];
    
    if (([[MyPetsIAPHelper sharedInstance] productPurchased:product.productIdentifier] &&
        ![product.productIdentifier hasSuffix:@"month"]) || ([helper daysRemainingOnSubscription] > 0 && ![product.productIdentifier hasSuffix:@"month"])) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([product.productIdentifier hasSuffix:@"month"]) {
            if ([PFUser currentUser].isAuthenticated) {
                if ([helper daysRemainingOnSubscription] > 0) {
                    buyButton.frame = CGRectMake(0, 0, 92, 37);
                    [buyButton setTitle:NSLS(@"Renew") forState:UIControlStateNormal];
                    buyButton.tag = indexPath.row;
                    [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = buyButton;
                } else {
                    buyButton.frame = CGRectMake(0, 0, 92, 37);
                    [buyButton setTitle:NSLS(@"Subscribe") forState:UIControlStateNormal];
                    buyButton.tag = indexPath.row;
                    [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = buyButton;
                }
            } else {
                cell.accessoryView = nil;
            }
        } else {
            buyButton.frame = CGRectMake(0, 0, 72, 37);
            [buyButton setTitle:NSLS(@"Buy") forState:UIControlStateNormal];
            buyButton.tag = indexPath.row;
            [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = buyButton;
        }
    }
    
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 60)];
        IAPHelper * helper = [[IAPHelper alloc] init];
        [headerView setBackgroundColor:[UIColor grayColor]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.bounds.size.width - 20, 60)];
        label.text = [helper getExpiryDateString];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [headerView addSubview:label];
        return headerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 66.0f;
}

- (void)buyButtonTapped:(id)sender
{
    
    NSArray *transactions = [[SKPaymentQueue defaultQueue] transactions];
    NSLog(@"Have to clean transactions...%d",transactions.count);

    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
    [[MyPetsIAPHelper sharedInstance] buyProduct:product];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![PFUser currentUser].isAuthenticated) {
        [self signOutTapped:nil];
    }else{
        NSArray *transactions = [[SKPaymentQueue defaultQueue] transactions];
        NSLog(@"Have to clean transactions...%d",transactions.count);
        
        
        SKProduct *product = _products[indexPath.row];
        
        [[MyPetsIAPHelper sharedInstance] buyProduct:product];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [[MPGoogle shared] sendEventWithCategory:@"Facebook" action:@"Start Connection" label:@""];
        
        [self showHUD_ConectandoNoFacebook];
        
        [[[MPFacebook shared] taskLoginFacebook] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                             withBlock:^id(BFTask *task) {
                                                                 if (!task.error) {
                                                                     if (alertView.tag == 1) {
                                                                         [self reload];
                                                                     }else{
                                                                         [self restoreTapped:nil];
                                                                     }
                                                                     
                                                                     [self dismissHUD];
                                                                     
                                                                     [[MPGoogle shared] sendEventWithCategory:@"Facebook" action:@"End Connection" label:@"Success Connection"];
                                                                     
                                                                 }else{
                                                                     NSLog(@"error: %@", task.error.description);
                                                                     
                                                                     [self dismissHUD_NaoFoiPossivelConectarNoFacebook];
                                                                     
                                                                     [[MPGoogle shared] sendEventWithCategory:@"Facebook" action:@"End Connection" label:@"Error Connection"];
                                                                 }
                                                                 return nil;
                                                             }];
    }
}
@end
