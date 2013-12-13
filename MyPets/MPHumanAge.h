//
//  MPHumanAge.h
//  MyPets
//
//  Created by HP Developer on 13/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPHumanAge : NSObject

@property (nonatomic, strong) NSMutableArray *arrayFelino;
@property (nonatomic, strong) NSMutableArray *arrayCanino;

+ (id)shared;

@end
