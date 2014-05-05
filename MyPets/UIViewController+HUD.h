//
//  UIViewController+HUD.h
//  CheckBus
//
//  Created by HP Developer on 10/04/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HUD)

- (void)showHUD_ConectandoNoFacebook;

- (void)dismissHUD;
- (void)dismissHUD_NaoFoiPossivelConectarNoFacebook;
@end
