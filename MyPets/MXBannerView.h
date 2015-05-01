//
//  MXBannerView.h
//  PickUpSticks
//
//  Created by Henrique Morbin on 15/07/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "GADBannerView.h"

@interface MXBannerView : UIView <GADBannerViewDelegate>
{
    GADBannerView *bannerView_;
    UIButton *buttonClose;
}

- (BOOL)requestBanner:(NSString *)bannerId target:(id)target;

@end
