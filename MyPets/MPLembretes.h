//
//  MPLembretes.h
//  MyPets
//
//  Created by HP Developer on 22/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPLembretes : NSObject
@property (nonatomic, strong) NSArray *arrayLembretes;

+(id)shared;
@end
