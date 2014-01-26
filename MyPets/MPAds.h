//
//  MPAds.h
//  MyPets
//
//  Created by HP Developer on 26/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADBannerView.h"

@interface MPAds : NSObject <GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSString *admobID;

- (id)initWithScrollView:(UIScrollView *)scrollView_ viewController:(UIViewController *)viewController_ admobID:(NSString *)admobID_;
@end
