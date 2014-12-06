//
//  MXInAppPurchase.h
//  PickUpSticks
//
//  Created by Henrique Morbin on 24/08/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kIDENTIFIER_INAPP_REMOVEADS @"br.com.morbix.mypets.removeads"

@interface MXInAppPurchase : NSObject

+ (instancetype)shared;

- (void)saveRemoveAdsPurchasedFromObserver:(BOOL)observer;
- (BOOL)checkRemoveAdsPurchased;

@end
