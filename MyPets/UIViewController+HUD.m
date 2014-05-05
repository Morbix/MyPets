//
//  UIViewController+HUD.m
//  CheckBus
//
//  Created by HP Developer on 10/04/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "UIViewController+HUD.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"

@implementation UIViewController (HUD)


- (void)showHUD_ConectandoNoFacebook
{
    [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeLinear];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    [MMProgressHUD showWithTitle:NSLS(@"Autenticação") status:NSLS(@"Conectando ao Facebook...")];
}

- (void)dismissHUD
{
    [MMProgressHUD dismiss];
}


- (void)dismissHUD_NaoFoiPossivelConectarNoFacebook
{
    [MMProgressHUD dismissWithError:NSLS(@"Não foi possível se conectar ao Facebook.")];
}

@end
