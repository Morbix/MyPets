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
    [self.bannerView setFrame:CGRectMake((self.viewController.view.frame.size.width/2) - (self.bannerView.frame.size.width/2),
                                         self.viewController.view.frame.size.height-self.bannerView.frame.size.height,
                                         self.bannerView.frame.size.width,
                                         self.bannerView.frame.size.height)];
    
    self.bannerView.adUnitID = self.admobID;
    
    
    self.bannerView.rootViewController = self.viewController;
    self.bannerView.delegate = self;
    [self.viewController.view.superview addSubview:self.bannerView];
    //[self addBannerConstraints];
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ @"d739ce5a07568c089d5498568147e06a", @"7229798c8732c56f536549c0f153d45f", @"67ea2ee367ec3302ebc5a642671bafaf", GAD_SIMULATOR_ID];
    [self.bannerView loadRequest: request];
}

- (void)addBannerConstraints
{
    [self.bannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    // Width constraint, half of parent view width
    [self.viewController.view.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.bannerView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:kIPHONE ? 320 : 728]];
    
    // Height constraint, half of parent view height
    [self.viewController.view.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.bannerView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:kIPHONE ? 50 : 90]];
    
    // Center horizontally
    [self.viewController.view.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.bannerView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.viewController.view.superview
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Center vertically
    [self.viewController.view.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.bannerView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.viewController.view.superview
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
}

#pragma mark - GADBannerDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    //PRETTY_FUNCTION;
    UIEdgeInsets edge =  UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.bannerView.frame.size.height*1, self.scrollView.contentInset.right);
    //[self.collection setScrollIndicatorInsets:edge];
    [self.scrollView setContentInset:edge];
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    //SHOW_ERROR(error);
}
@end
