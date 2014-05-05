//
//  MPGoogle.h
//  MyPets
//
//  Created by HP Developer on 03/05/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPGoogle : NSObject

+ (id)shared;
- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label;
- (void)sendTelaWithName:(NSString *)screen;
@end
