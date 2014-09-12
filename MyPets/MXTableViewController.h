//
//  MXTableViewController.h
//  MyPets
//
//  Created by HP Developer on 12/09/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MXTableViewController : UITableViewController
@property (strong, nonatomic) MXBannerHeaderView *bannerView;
@property (strong, nonatomic) UIView  *headerView;

- (void)createBannerView;
- (void)requestBanner:(NSString *)bannerId;
@end
