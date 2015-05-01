//
//  MXBannerView.m
//  PickUpSticks
//
//  Created by Henrique Morbin on 15/07/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MXBannerView.h"

#import "MXInAppPurchase.h"

#import "MXGoogleAnalytics.h"

@interface MXBannerView () <UIActionSheetDelegate>

@end

@implementation MXBannerView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (aDecoder) {
        self = [super initWithCoder:aDecoder];
    }else{
        self = [super init];
    }
    
    if (self) {
        self.backgroundColor    = [UIColor clearColor];
        self.clipsToBounds      = YES;
        
        // Criar uma visualização do tamanho padrão na parte inferior da tela.
        // Available AdSize constants are explained in GADAdSize.h.
        bannerView_ = [[GADBannerView alloc] initWithAdSize: [self getSize]];
        [bannerView_ setDelegate:self];
        
        [self addSubview:bannerView_];
        [self addBannerConstraints];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchasedNotification) name:kIDENTIFIER_INAPP_REMOVEADS object:nil];
    }
    return self;
}

- (GADAdSize)getSize
{
    return kIPHONE ? kGADAdSizeBanner : kGADAdSizeLeaderboard;
}

- (void)addButtonClose
{
    if (buttonClose) {
        return;
    }
    
    buttonClose = [UIButton new];

    [self.superview addSubview:buttonClose];
    
    [buttonClose setTranslatesAutoresizingMaskIntoConstraints:NO];
    [buttonClose setImage:[UIImage imageNamed:@"Button_Close"] forState:UIControlStateNormal];
    [buttonClose setHidden:YES];
    [buttonClose addTarget:self action:@selector(buttonCloseTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonClose addConstraint:[NSLayoutConstraint constraintWithItem:buttonClose
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:kIPHONE ? 25 : 35]];
    
    // Height constraint, half of parent view height
    [buttonClose addConstraint:[NSLayoutConstraint constraintWithItem:buttonClose
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:kIPHONE ? 25 : 35]];
    
    int x = [self getX];
    // Center horizontally
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:buttonClose
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.superview
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:x]];
    
    int y = [self getY];
    // Center vertically
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:buttonClose
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.superview
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:y]];
}

- (int)getX
{
    int x = kIPHONE ? ((-320/2)+25) : ((-728/2)+35);
    return x;
}

- (int)getY
{
    int y = kIPHONE ? -50+(25/2) : -90+(35/2);
    return y;
}

- (void)addBannerConstraints
{
    [bannerView_ setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    // Width constraint, half of parent view width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bannerView_
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:kIPHONE ? 320 : 728]];
    
    // Height constraint, half of parent view height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bannerView_
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:kIPHONE ? 50 : 90]];
    
    // Center horizontally
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bannerView_
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Center vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bannerView_
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
}

- (BOOL)requestBanner:(NSString *)bannerId target:(id)target
{
    // Especificar o ID do bloco de anúncios.
    bannerView_.adUnitID = bannerId;
    
    // Permitir que o tempo de execução saiba qual UIViewController deve ser restaurado depois de levar
    // o usuário para onde quer que o anúncio vá e adicioná-lo à hierarquia de visualização.
    bannerView_.rootViewController = target;
    
    // Iniciar uma solicitação genérica para carregá-la com um anúncio.
    
    if ([MPTargets targetAds]) {
        if (![[MXInAppPurchase shared] checkRemoveAdsPurchased]) {
            GADRequest *request = [GADRequest request];
            request.testDevices = @[ @"d739ce5a07568c089d5498568147e06a", @"7229798c8732c56f536549c0f153d45f", @"67ea2ee367ec3302ebc5a642671bafaf", @"baaa2cc79e5dd8cfe3236be05ef6ed4d", GAD_SIMULATOR_ID];
            
            [bannerView_ loadRequest:request];
            
            [self addButtonClose];
            
            return YES;
        }
    }
    
    return FALSE;
}

#pragma mark - IBActions
- (void)buttonCloseTouched:(UIButton *)sender
{
    [MXGoogleAnalytics ga_trackEventWith:@"Ads" action:@"Close Touched" label:bannerView_.adUnitID];
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:kLABEL_Remove_Ads
                                                        delegate:self
                                               cancelButtonTitle:kLABEL_Cancel
                                          destructiveButtonTitle:kLABEL_Remove_Ads
                                               otherButtonTitles:kLABEL_Restore, nil];
    
    [action showFromRect:sender.frame inView:self.superview animated:YES];
}

#pragma mark - GADBannerDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    buttonClose.hidden = NO;
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    buttonClose.hidden = YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [MXGoogleAnalytics ga_trackEventWith:@"Ads" action:@"Remove Touched" label:bannerView_.adUnitID];
        [[MXInAppPurchase shared] buyProduct:kIDENTIFIER_INAPP_REMOVEADS block:^(NSError *error) {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:error.localizedDescription
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            }
        }];
    }else{
        if (buttonIndex == 1) {
            [MXGoogleAnalytics ga_trackEventWith:@"Ads" action:@"Restore Touched" label:bannerView_.adUnitID];
            
            [PFPurchase restore];
        }
    }
}

#pragma mark - Notification
- (void)purchasedNotification
{
    buttonClose.hidden = YES;
    if (bannerView_) {
        [bannerView_ removeFromSuperview];
        bannerView_ = nil;
    }
}
@end
