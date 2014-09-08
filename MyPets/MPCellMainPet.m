//
//  MPCellMainPet.m
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPCellMainPet.h"
#import <QuartzCore/QuartzCore.h>

@implementation MPCellMainPet

- (id)initWithDiv:(int)div andWidth:(int)width
{
    float w = width;
    self = [super initWithFrame:CGRectMake(0, 0, w/div, w/div)];
    if (self) {
        float borda = 6;
        float borda2 = 6;
        float fontSize = 28.0f;
        
        if (kIPHONE) {
            fontSize = (div==1)?28.0f:((div==2)?16.0f:12.0f);
        }
        
        self.imagemPet = [[UIImageView alloc] init];
        [self.imagemPet setFrame:CGRectMake(borda, borda, self.frame.size.width-(2*borda), self.frame.size.height-(2*borda))];
        [self.imagemPet setContentMode:UIViewContentModeScaleToFill];
        [self.imagemPet.layer setBorderColor:[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor];
        [self.imagemPet.layer setBorderColor:[UIColor colorWithRed:255.0f/255.0f green:202.0f/255.0f blue:80.0f/255.0f alpha:1.0f].CGColor];
        //[self.imagemPet.layer setBorderColor:[UIColor colorWithRed:219.0f/255.0f green:217.0f/255.0f blue:211.0f/255.0f alpha:1.0f].CGColor];
        [self.imagemPet.layer setBorderWidth:4.0f];
        [self.imagemPet.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.imagemPet.layer setShadowOffset:CGSizeMake(2, 2)];
        [self.imagemPet.layer setShadowOpacity:0.0];
        [self.imagemPet.layer setShadowRadius:2.0];
        //[self.imagemPet setImage:[UIImage imageNamed:@"dog.jpg"]];
        
        
        self.imagemSombra = [[UIImageView alloc] init];
        [self.imagemSombra setFrame:CGRectMake(0, self.imagemPet.frame.size.height/2, self.imagemPet.frame.size.width, self.imagemPet.frame.size.height/2)];
        [self.imagemSombra setContentMode:UIViewContentModeScaleToFill];
        [self.imagemSombra setImage:[UIImage imageNamed:@"fotoSombra.png"]];
        [self.imagemPet addSubview:self.imagemSombra];
        
        
        
        self.labelNome = [[UILabel alloc] init];
        [self.labelNome setFrame:CGRectMake(borda2, self.imagemSombra.frame.size.height-(self.imagemSombra.frame.size.height/4)-(borda2), self.imagemSombra.frame.size.width-(2*borda2), self.imagemSombra.frame.size.height/4)];
        [self.labelNome setTextAlignment:NSTextAlignmentLeft];
        [self.labelNome setTextColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
        [self.labelNome setBackgroundColor:[UIColor clearColor]];
        [self.labelNome setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.labelNome setMinimumScaleFactor:0.8];
        [self.labelNome setAdjustsFontSizeToFitWidth:YES];
        [self.labelNome setFont:[UIFont boldSystemFontOfSize:fontSize]];
        [self.labelNome setShadowColor:[UIColor blackColor]];
        [self.labelNome setShadowOffset:CGSizeMake(0.0f, -0.0f)];
        [self.imagemSombra addSubview:self.labelNome];
        
        [self addSubview:self.imagemPet];
    }
    return self;
}

@end
