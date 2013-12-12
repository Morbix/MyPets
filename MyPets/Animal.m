//
//  Animal.m
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "Animal.h"
#import "Banho.h"
#import "Consulta.h"
#import "Fotos.h"
#import "Medicamento.h"
#import "Vacina.h"
#import "Vermifugo.h"


@implementation Animal

@dynamic cDataNascimento;
@dynamic cEspecie;
@dynamic cFoto;
@dynamic cFoto_Path;
@dynamic cFoto_Path_Thumb;
@dynamic cID;
@dynamic cLocation;
@dynamic cMapa;
@dynamic cNeedUpdate;
@dynamic cNome;
@dynamic cObs;
@dynamic cRaca;
@dynamic cSexo;
@dynamic cArrayBanhos;
@dynamic cArrayConsultas;
@dynamic cArrayFotos;
@dynamic cArrayMedicamentos;
@dynamic cArrayVacinas;
@dynamic cArrayVermifugos;

- (UIImage *)getFoto
{
    if (self.cFoto) {
        return [UIImage imageWithData:self.cFoto];
    }
    return [UIImage imageNamed:@"fotoDefault.png"];
}

- (NSString *)getNome
{
    return self.cNome;
}

- (NSString *)getDescricao
{
    NSString * raca = self.cRaca;
    NSString * sexo = NSLocalizedString(@"Macho", nil);
    
    if (![self.cSexo isEqualToString:NSLocalizedString(@"Macho",nil)]) {
        sexo = NSLocalizedString(@"Fêmea", nil);
    }
    
    if ([raca isEqualToString:@""]) {
        raca = @"n/a";
    }else {
        raca = self.cRaca;
    }
    
    return [NSString stringWithFormat:@"%@ - %@",raca,sexo];
}
@end
