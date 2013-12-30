//
//  MPMainViewController.h
//  MyPets
//
//  Created by Henrique Morbin on 25/10/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface MPMainViewController : UIViewController <GADBannerViewDelegate>
{
    GADBannerView *bannerView_;
}
@property (strong, nonatomic) IBOutlet UICollectionView *collection;
@end
