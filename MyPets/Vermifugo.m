//
//  Vermifugo.m
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "Vermifugo.h"
#import "Animal.h"
#import "MPLibrary.h"
#import "UIImage+ResizeAndCrop.h"

@implementation Vermifugo

@dynamic cData;
@dynamic cDataVacina;
@dynamic cDose;
@dynamic cID;
@dynamic cLembrete;
@dynamic cObs;
@dynamic syncID;
@dynamic cFoto_Edited;
@dynamic cPeso;
@dynamic cSelo;
@dynamic cAnimal;

- (UIImage *)getFoto
{
    UIImage *seloCompleto = nil;
    
    if (self.cSelo) {
        seloCompleto = [UIImage imageWithData:self.cSelo];
    }else{
        seloCompleto = [UIImage imageNamed:@"comprimidos.png"];
    }
    
    CGSize expectedSize = CGSizeMake(320, 160);
    float scale;
    if (seloCompleto.size.width > seloCompleto.size.height) {
        //paisagem
        scale = seloCompleto.size.height / expectedSize.height;
    }else{
        //retrato
        scale = seloCompleto.size.width / expectedSize.width;
    }
    CGSize newSize = CGSizeMake(seloCompleto.size.width / scale, seloCompleto.size.height / scale);
    if (newSize.width < 320) {
        scale = seloCompleto.size.width / expectedSize.width;
        newSize = CGSizeMake(seloCompleto.size.width / scale, seloCompleto.size.height / scale);
    }
    
    UIImage *resizedImage = [MPLibrary imageWithImage:seloCompleto scaledToSize:newSize];
    
    CGPoint offset = CGPointMake((newSize.width/2)-(expectedSize.width/2), (newSize.height/2)-(expectedSize.height/2));
    
    return [resizedImage resizeToSize:newSize thenCropWithRect:CGRectMake(offset.x, offset.y, expectedSize.width, expectedSize.height)];
}

- (UIImage *)getFotoCompleta
{
    UIImage *seloCompleto = nil;
    
    if (self.cSelo) {
        seloCompleto = [UIImage imageWithData:self.cSelo];
    }else{
        seloCompleto = [UIImage imageNamed:@"vacinaDefault.jpg"];
    }
    
    return seloCompleto;
}
@end
