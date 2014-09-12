//
//  MXBannerHeaderView.m
//  MyPets
//
//  Created by HP Developer on 12/09/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MXBannerHeaderView.h"

@implementation MXBannerHeaderView

- (int)getX
{
    int x = kIPHONE ? ((320/2)-25) : ((728/2)-35);
    return x;
}

- (int)getY
{
    //int y = kIPHONE ? (50/2)-(25/2) : (90/2)-(35/2);
    int y = kIPHONE ? (50/2)-25+(25/2) : (90/2)-35+(35/4);
    return y;
}

@end
