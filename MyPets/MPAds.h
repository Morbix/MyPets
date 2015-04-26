//
//  MPAds.h
//  MyPets
//
//  Created by HP Developer on 26/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#define kBanner_Main kIPHONE ? @"ca-app-pub-8687233994493144/1806932365" : @"ca-app-pub-8687233994493144/2309252362"
#define kBanner_Pet kIPHONE ? @"ca-app-pub-8687233994493144/9330199164" : @"ca-app-pub-8687233994493144/8355785965"
#define kBanner_Pet_Edit kIPHONE ? @"ca-app-pub-8687233994493144/1661841561" : @"ca-app-pub-8687233994493144/9832519166"
#define kBanner_Listagem kIPHONE ? @"ca-app-pub-8687233994493144/7708375167" : @"ca-app-pub-8687233994493144/3785985566"
#define kBanner_Edits kIPHONE ? @"ca-app-pub-8687233994493144/9185108364" : @"ca-app-pub-8687233994493144/5262718762"
#define kBanner_Config kIPHONE ? @"ca-app-pub-8687233994493144/3138574766" : @"ca-app-pub-8687233994493144/8216185160"
#define kBanner_Lembretes kIPHONE ? @"ca-app-pub-8687233994493144/4615307968" : @"ca-app-pub-8687233994493144/6739451968"

@interface MPAds : NSObject <GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSString *admobID;

- (id)initWithScrollView:(UIScrollView *)scrollView_ viewController:(UIViewController *)viewController_ admobID:(NSString *)admobID_;
@end
