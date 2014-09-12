//
//  UITableViewController+MXAds.m
//  MyPets
//
//  Created by HP Developer on 12/09/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "UITableViewController+MXAds.h"

@implementation UITableViewController (MXAds)

@dynamic headerView;
@dynamic bannerView;

- (void)createBannerView
{
    CGRect frame = CGRectMake(0,0,
                              kIPHONE ? 320.0f : 768.0f,
                              kIPHONE ? 50.0f : 90.0f);
    
    self.headerView = [[UIView alloc] initWithFrame:frame];
    [self.headerView setBackgroundColor:[UIColor clearColor]];
    
    
    self.bannerView = [[MXBannerHeaderView alloc] initWithCoder:nil];
    [self.bannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.headerView addSubview:self.bannerView];
    [self addConstraintsToView:self.bannerView beFullScreenOfView:self.headerView];
}

- (void)requestBanner:(NSString *)bannerId
{
    if (self.bannerView) {
        if ([self.bannerView requestBanner:bannerId target:self]) {
            self.tableView.tableHeaderView = self.headerView;
        }else{
            self.tableView.tableHeaderView = nil;
        }
    }
}

- (void)addConstraintsToView:(UIView *)view beFullScreenOfView:(UIView *)parent
{
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeWidth
                                                      multiplier:1.0
                                                        constant:0]];
    
    // Height constraint, half of parent view height
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeHeight
                                                      multiplier:1.0
                                                        constant:0]];
    
    // Center horizontally
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                       attribute:NSLayoutAttributeCenterX
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeCenterX
                                                      multiplier:1.0
                                                        constant:0.0]];
    
    // Center vertically
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                       attribute:NSLayoutAttributeCenterY
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeCenterY
                                                      multiplier:1.0
                                                        constant:0.0]];
}
@end
