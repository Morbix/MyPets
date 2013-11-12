//
//  MSMasterViewController.m
//  MSNavigationPaneViewController
//
//  Created by Eric Horacek on 11/20/12.
//  Copyright (c) 2012-2013 Monospace Ltd. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MSMasterViewController.h"
#import "MPCoreDataService.h"
#import "Animal.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFlatColor.h"

NSString * const MSMasterViewControllerCellReuseIdentifier = @"MSMasterViewControllerCellReuseIdentifier";

typedef NS_ENUM(NSUInteger, MSMasterViewControllerTableViewSectionType) {
    MSMasterViewControllerTableViewSectionTypeAppearanceTypes,
    MSMasterViewControllerTableViewSectionTypeControls,
    MSMasterViewControllerTableViewSectionTypeAbout,
    MSMasterViewControllerTableViewSectionTypeCount
};

@interface MSMasterViewController () <MSNavigationPaneViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *paneViewControllerTitles;
@property (nonatomic, strong) NSDictionary *paneViewControllerIdentifiers;
@property (nonatomic, strong) NSDictionary *paneViewControllerAppearanceTypes;
@property (nonatomic, strong) NSDictionary *sectionTitles;
@property (nonatomic, strong) NSArray *tableViewSectionBreaks;

@property (nonatomic, strong) UIBarButtonItem *paneStateBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *paneRevealBarButtonItem;

- (void)navigationPaneRevealBarButtonItemTapped:(id)sender;

@end

@implementation MSMasterViewController

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationPaneViewController.delegate = self;
    
    // Default to the "None" appearance type
    [self transitionToViewController:MSPaneViewControllerTypeAppearanceNone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callbackPetsCompleted:) name:MTPSNotificationPets object:nil];
}

#pragma mark - MSMasterViewController

- (void)initialize
{
    self.paneViewControllerType = NSUIntegerMax;
    self.paneViewControllerTitles = @{
        @(MSPaneViewControllerTypeAppearanceNone) : @"None",
        @(MSPaneViewControllerTypeAppearanceParallax) : @"Parallax",
        @(MSPaneViewControllerTypeAppearanceZoom) : @"Zoom",
        @(MSPaneViewControllerTypeAppearanceFade) : @"Fade",
        @(MSPaneViewControllerTypeControls) : @"Controls",
        @(MSPaneViewControllerTypeMonospace) : @"Monospace Ltd."
    };
    
    self.paneViewControllerIdentifiers = @{
        @(MSPaneViewControllerTypeAppearanceNone) : @"mainViewController"
    };
    
    self.paneViewControllerAppearanceTypes = @{
        @(MSPaneViewControllerTypeAppearanceNone) : @(MSNavigationPaneAppearanceTypeNone),
        @(MSPaneViewControllerTypeAppearanceParallax) : @(MSNavigationPaneAppearanceTypeParallax),
        @(MSPaneViewControllerTypeAppearanceZoom) : @(MSNavigationPaneAppearanceTypeZoom),
        @(MSPaneViewControllerTypeAppearanceFade) : @(MSNavigationPaneAppearanceTypeFade),
    };
    
    self.sectionTitles = @{
        @(MSMasterViewControllerTableViewSectionTypeAppearanceTypes) : @"Appearance Types",
        @(MSMasterViewControllerTableViewSectionTypeControls) : @"Controls",
        @(MSMasterViewControllerTableViewSectionTypeAbout) : @"About",
    };
    
    self.tableViewSectionBreaks = @[
        @(MSPaneViewControllerTypeControls),
        @(MSPaneViewControllerTypeMonospace),
        @(MSPaneViewControllerTypeCount)
    ];
}

- (MSPaneViewControllerType)paneViewControllerTypeForIndexPath:(NSIndexPath *)indexPath
{
    MSPaneViewControllerType paneViewControllerType;
    if (indexPath.section == 0) {
        paneViewControllerType = indexPath.row;
    } else {
        paneViewControllerType = ([self.tableViewSectionBreaks[(indexPath.section - 1)] integerValue] + indexPath.row);
    }
    NSAssert(paneViewControllerType < MSPaneViewControllerTypeCount, @"Invalid Index Path");
    return paneViewControllerType;
}

- (void)transitionToViewController:(MSPaneViewControllerType)paneViewControllerType
{
    if (paneViewControllerType == self.paneViewControllerType) {
        [self.navigationPaneViewController setPaneState:MSNavigationPaneStateClosed animated:YES completion:nil];
        return;
    }
    
    BOOL animateTransition = self.navigationPaneViewController.paneViewController != nil;
    
    UIViewController *paneViewController = [self.navigationPaneViewController.storyboard instantiateViewControllerWithIdentifier:self.paneViewControllerIdentifiers[@(paneViewControllerType)]];
    
    paneViewController.navigationItem.title = self.paneViewControllerTitles[@(paneViewControllerType)];
    
    self.paneRevealBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MSBarButtonIconNavigationPane.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(navigationPaneRevealBarButtonItemTapped:)];
    //paneViewController.navigationItem.leftBarButtonItem = self.paneRevealBarButtonItem;
    
    //self.paneStateBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(navigationPaneStateBarButtonItemTapped:)];
    //paneViewController.navigationItem.rightBarButtonItem = self.paneStateBarButtonItem;

    // Update pane state button titles
    self.navigationPaneViewController.openStateRevealWidth = 265.0;
    self.navigationPaneViewController.paneViewSlideOffAnimationEnabled = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    
    UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:paneViewController];
    [self.navigationPaneViewController setPaneViewController:paneNavigationViewController animated:animateTransition completion:nil];
    
    self.paneViewControllerType = paneViewControllerType;
}



- (void)navigationPaneRevealBarButtonItemTapped:(id)sender
{
    [self.navigationPaneViewController setPaneState:MSNavigationPaneStateOpen animated:YES completion:nil];
}




#pragma mark - MSNavigationPaneViewControllerDelegate

- (void)navigationPaneViewController:(MSNavigationPaneViewController *)navigationPaneViewController didUpdateToPaneState:(MSNavigationPaneState)state
{
    
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[MPCoreDataService shared] arrayPets] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pet"];
    
    UILabel *labelNome      = (UILabel *)[cell viewWithTag:10];
    UILabel *labelDescricao = (UILabel *)[cell viewWithTag:20];
    UILabel *labelIdade     = (UILabel *)[cell viewWithTag:30];
    UIImageView *imagemFoto = (UIImageView *)[cell viewWithTag:40];
    
    Animal *animal = [[[MPCoreDataService shared] arrayPets] objectAtIndex:indexPath.row];
    
    [labelNome setText:[animal getNome]];
    [labelNome setTextColor:[UIFlatColor alizarinColor]];
    
    [labelDescricao setText:[animal getDescricao]];
    [labelDescricao setTextColor:[UIFlatColor orangeColor]];
    
    [labelIdade setTextColor:[UIFlatColor orangeColor]];
    
    [imagemFoto setImage:[animal getFoto]];
    [imagemFoto.layer setBorderColor:[UIColor colorWithWhite:0.98f alpha:1.0f].CGColor];
    [imagemFoto.layer setBorderWidth:2.0f];
    [imagemFoto.layer setShadowColor:[UIColor blackColor].CGColor];
    [imagemFoto.layer setShadowOffset:CGSizeMake(2, 2)];
    [imagemFoto.layer setShadowOpacity:0.0];
    [imagemFoto.layer setShadowRadius:1.0];
    
    
    //[self addShaddow:&labelNome];
    //[self addShaddow:&labelDescricao];
    //[self addShaddow:&labelIdade];
    
    return cell;
}

- (void)addShaddow:(UIView *__autoreleasing*)object
{
    [[*object layer] setShadowColor:[UIColor whiteColor].CGColor];
    [[*object layer] setShadowOffset:CGSizeMake(1, 1)];
    [[*object layer] setShadowOpacity:0.5];
    [[*object layer] setShadowRadius:1.0];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

#pragma mark - MTNotifications
- (void)callbackPetsCompleted:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MTPSNotificationPets object:nil];
    
    if (notification.userInfo) {
        NSLog(@"error: %s", __PRETTY_FUNCTION__);
    }else{
        [self.tabela reloadData];
    }
}


@end
