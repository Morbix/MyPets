//
//  MPPetViewController.h
//  MyPets
//
//  Created by HP Developer on 10/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface MPPetViewController : UITableViewController <GADBannerViewDelegate>
{
    GADBannerView *bannerView_;
}
@end
