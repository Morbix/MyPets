//
//  MPCellMainPet.h
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPCellMainPet : UIView

@property (nonatomic, strong) UIImageView *imagemPet;
@property (nonatomic, strong) UIImageView *imagemSombra;
@property (nonatomic, strong) UILabel *labelNome;

- (id)initWithDiv:(int)div;

@end
