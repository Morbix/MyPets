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
#import "MPHumanAge.h"
#import "MPLibrary.h"


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
    NSString * raca = self.cRaca ? self.cRaca : @"";
    NSString * sexo = self.cSexo ? self.cSexo : NSLS(@"Macho");
    
    if (![sexo isEqualToString:NSLS(@"Macho")]) {
        sexo = NSLS(@"Fêmea");
    }
    
    if ([raca isEqualToString:@""]) {
        raca = @"n/a";
    }else {
        raca = self.cRaca;
    }
    
    return [NSString stringWithFormat:@"%@ - %@",raca,sexo];
}

- (NSString *)getIdade
{
    return [NSString stringWithFormat:@"%@ %@",[self idadeDoAnimal:self],[self idadeHumanaDoAnimal:self]];
}

- (NSString *)idadeDoAnimal:(Animal *)_animal
{
    if (_animal.cDataNascimento) {
        
        NSDate *startDate = _animal.cDataNascimento;
        NSDate *endDate   = [NSDate date];
        
        unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        
        NSDateComponents *comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:startDate  toDate:endDate  options:0];
        
        int year   = [comps year];
        int months = [comps month];
        int days   = [comps day];
        
        NSString * _ano = @"";
        NSString * _mes = @"";
        NSString * _dia = @"";
        
        switch (year) {
            case 0:
                _ano = [NSString stringWithFormat:@""];
                break;
            case 1:
                _ano = [NSString stringWithFormat:@"%d %@",year,NSLocalizedString(@"ano",nil)];
                break;
                
            default:
                _ano = [NSString stringWithFormat:@"%d %@",year,NSLocalizedString(@"anos",nil)];
                break;
        }
        
        switch (months) {
            case 0:
                _mes = [NSString stringWithFormat:@""];
                break;
            case 1:
                if (year > 0) {
                    _mes = [NSString stringWithFormat:@" %d %@",months,NSLocalizedString(@"mês",nil)];
                }else {
                    _mes = [NSString stringWithFormat:@"%d %@",months,NSLocalizedString(@"mês",nil)];
                }
                break;
                
            default:
                if (year > 0) {
                    _mes = [NSString stringWithFormat:@" %d %@",months,NSLocalizedString(@"meses",nil)];
                }else {
                    _mes = [NSString stringWithFormat:@"%d %@",months,NSLocalizedString(@"meses",nil)];
                }
                break;
        }
        
        if (year == 0) {
            switch (days) {
                case 0:
                    if (year+months > 0) {
                        _dia = [NSString stringWithFormat:@" 0 %@",NSLocalizedString(@"dia",nil)];
                    }else {
                        _dia = [NSString stringWithFormat:@"0 %@",NSLocalizedString(@"dia",nil)];
                    }
                    break;
                case 1:
                    if (year+months > 0) {
                        _dia = [NSString stringWithFormat:@" %d %@",days, NSLocalizedString(@"dia",nil)];
                    }else {
                        _dia = [NSString stringWithFormat:@"%d %@",days,NSLocalizedString(@"dia",nil)];
                    }
                    break;
                    
                default:
                    if (year+months > 0) {
                        _dia = [NSString stringWithFormat:@" %d %@",days, NSLocalizedString(@"dias",nil)];
                    }else {
                        _dia = [NSString stringWithFormat:@"%d %@",days,NSLocalizedString(@"dias",nil)];
                    }
                    break;
            }
        }
        
        
        return [NSString stringWithFormat:@"%@%@%@",_ano,_mes,_dia];
    }
    
    return [NSString stringWithFormat:@"0 %@",NSLocalizedString(@"dia",nil)];
}

- (NSString *)idadeHumanaDoAnimal:(Animal *)_animal
{
    
    if (_animal.cDataNascimento) {
        NSDate *startDate = _animal.cDataNascimento;
        NSDate *endDate   = [NSDate date];
        
        unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        
        NSDateComponents *comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:startDate  toDate:endDate  options:0];
        
        int year   = [comps year];
        int months = [comps month];
        //int days   = [comps day];
        
        if (_animal.cEspecie) {
            if ([_animal.cEspecie isEqualToString:NSLS(@"Canino")]) {
                NSMutableArray *arrayCanino = [[MPHumanAge shared] arrayCanino];
                
                int meses = months + (year*12);
                int i = 0;
                for (NSArray * a in arrayCanino) {
                    
                    if (meses < [[a objectAtIndex:0] intValue]) {
                        break;
                    }else{
                        i++;
                    }
                }
                
                if (i == [arrayCanino count]) {
                    return [NSString stringWithFormat:@"(200 %@)",NSLS(@"anos humanos")];
                }else{
                    return [NSString stringWithFormat:@"(%d %@)",[[(NSArray*)[arrayCanino objectAtIndex:i-1] objectAtIndex:1] intValue],NSLS(@"anos humanos")];
                }
                
                
            }else if ([_animal.cEspecie isEqualToString:NSLS(@"Felino")]) {
                NSMutableArray *arrayFelino = [[MPHumanAge shared] arrayFelino];
                
                int meses = months + (year*12);
                int i = 0;
                for (NSArray * a in arrayFelino) {
                    if (meses < [[a objectAtIndex:0] intValue]) {
                        break;
                    }else{
                        i++;
                    }
                }
                
                if (i == [arrayFelino count]) {
                    return [NSString stringWithFormat:@"(96 %@)",NSLS(@"anos humanos")];
                }else{
                    return [NSString stringWithFormat:@"(%d %@)",[[(NSArray*)[arrayFelino objectAtIndex:i-1] objectAtIndex:1] intValue],NSLS(@"anos humanos")];
                }
            }
        }
    }
    
    return @"";
}

#pragma mark - Arrays
- (NSArray *)getNextVacinas
{
    return [self getJustNextsFrom:[self.cArrayVacinas allObjects] andInverse:NO];
}

- (NSArray *)getNextVermifugos
{
    return [self getJustNextsFrom:[self.cArrayVermifugos allObjects] andInverse:NO];
}

- (NSArray *)getNextConsultas
{
    return [self getJustNextsFrom:[self.cArrayConsultas allObjects] andInverse:NO];
}

- (NSArray *)getNextBanhos
{
    return [self getJustNextsFrom:[self.cArrayBanhos allObjects] andInverse:NO];
}

- (NSArray *)getPreviousVacinas
{
    return [self getJustNextsFrom:[self.cArrayVacinas allObjects] andInverse:YES];
}

- (NSArray *)getPreviousVermifugos
{
    return [self getJustNextsFrom:[self.cArrayVermifugos allObjects] andInverse:YES];
}

- (NSArray *)getPreviousConsultas
{
    return [self getJustNextsFrom:[self.cArrayConsultas allObjects] andInverse:YES];
}

- (NSArray *)getPreviousBanhos
{
    return [self getJustNextsFrom:[self.cArrayBanhos allObjects] andInverse:YES];
}

- (NSArray *)getJustNextsFrom:(NSArray *)array andInverse:(BOOL)inverse
{
    NSMutableArray *sortArray = [NSMutableArray arrayWithArray:array];
    [MPLibrary sortMutableArray:&sortArray withAttribute:@"cData" andAscending:NO];
    
    NSMutableArray *filteredArray = [NSMutableArray new];
    for (id object in sortArray) {
        NSDate * date = [object valueForKey:@"cData"];
        if (([date compare:[NSDate date]] == (!inverse ? NSOrderedDescending : NSOrderedAscending))|| ((date == nil) && inverse)) {
            [filteredArray addObject:object];
        }
    }
    
    return filteredArray;
}
@end
