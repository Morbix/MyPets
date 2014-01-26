//
//  MPAds.m
//  MyPets
//
//  Created by HP Developer on 26/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPAds.h"

@implementation MPAds

- (id)initWithScrollView:(UIScrollView *)scrollView_ viewController:(UIViewController *)viewController_ admobID:(NSString *)admobID_
{
    self = [super init];
    if (self) {
        self.scrollView     = scrollView_;
        self.viewController = viewController_;
        self.admobID        = admobID_;
        
        [self loadBanner];
    }
    return self;
}

#pragma mark - Métodos
- (void)loadBanner
{
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    [self.bannerView setFrame:CGRectMake(0, self.viewController.view.frame.size.height-self.bannerView.frame.size.height, self.bannerView.frame.size.width, self.bannerView.frame.size.height)];
    
    self.bannerView.adUnitID = self.admobID;
    
    
    self.bannerView.rootViewController = self.viewController;
    self.bannerView.delegate = self;
    [self.viewController.view addSubview:self.bannerView];
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ @"d739ce5a07568c089d5498568147e06a", @"7229798c8732c56f536549c0f153d45f", GAD_SIMULATOR_ID];
    request.testing = NO;
    [self.bannerView loadRequest: request];
}

#pragma mark - GADBannerDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    //PRETTY_FUNCTION;
    UIEdgeInsets edge =  UIEdgeInsetsMake(self.scrollView.scrollIndicatorInsets.top, self.scrollView.scrollIndicatorInsets.left, self.bannerView.frame.size.height*1, self.scrollView.scrollIndicatorInsets.right);
    //[self.collection setScrollIndicatorInsets:edge];
    [self.scrollView setContentInset:edge];
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    //SHOW_ERROR(error);
}
@end
