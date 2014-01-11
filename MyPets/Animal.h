//
//  Animal.h
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Banho, Consulta, Fotos, Medicamento, Vacina, Vermifugo, Peso;

@interface Animal : NSManagedObject

@property (nonatomic, retain) NSDate * cDataNascimento;
@property (nonatomic, retain) NSString * cEspecie;
@property (nonatomic, retain) NSData * cFoto;
@property (nonatomic, retain) NSString * cFoto_Path;
@property (nonatomic, retain) NSString * cFoto_Path_Thumb;
@property (nonatomic, retain) NSString * cID;
@property (nonatomic, retain) NSString * cLocation;
@property (nonatomic, retain) NSData * cMapa;
@property (nonatomic, retain) NSNumber * cNeedUpdate;
@property (nonatomic, retain) NSNumber * cFoto_Edited;
@property (nonatomic, retain) NSString * cNome;
@property (nonatomic, retain) NSString * cObs;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) NSString * cRaca;
@property (nonatomic, retain) NSString * cSexo;
@property (nonatomic, retain) NSSet *cArrayBanhos;
@property (nonatomic, retain) NSSet *cArrayConsultas;
@property (nonatomic, retain) NSSet *cArrayFotos;
@property (nonatomic, retain) NSSet *cArrayMedicamentos;
@property (nonatomic, retain) NSSet *cArrayVacinas;
@property (nonatomic, retain) NSSet *cArrayVermifugos;
@property (nonatomic, retain) NSSet *cArrayPesos;

- (UIImage *)getFoto;
- (NSString *)getNome;
- (NSString *)getDescricao;
- (NSString *)getIdade;

#pragma mark - Arrays
- (int)getUpcomingTotal;
- (NSArray *)getNextVacinas;
- (NSArray *)getNextVermifugos;
- (NSArray *)getNextConsultas;
- (NSArray *)getNextBanhos;
- (NSArray *)getNextMedicamentos;
- (NSArray *)getPreviousVacinas;
- (NSArray *)getPreviousVermifugos;
- (NSArray *)getPreviousConsultas;
- (NSArray *)getPreviousBanhos;
- (NSArray *)getPreviousMedicamentos;
@end

@interface Animal (CoreDataGeneratedAccessors)

- (void)addCArrayBanhosObject:(Banho *)value;
- (void)removeCArrayBanhosObject:(Banho *)value;
- (void)addCArrayBanhos:(NSSet *)values;
- (void)removeCArrayBanhos:(NSSet *)values;

- (void)addCArrayConsultasObject:(Consulta *)value;
- (void)removeCArrayConsultasObject:(Consulta *)value;
- (void)addCArrayConsultas:(NSSet *)values;
- (void)removeCArrayConsultas:(NSSet *)values;

- (void)addCArrayFotosObject:(Fotos *)value;
- (void)removeCArrayFotosObject:(Fotos *)value;
- (void)addCArrayFotos:(NSSet *)values;
- (void)removeCArrayFotos:(NSSet *)values;

- (void)addCArrayMedicamentosObject:(Medicamento *)value;
- (void)removeCArrayMedicamentosObject:(Medicamento *)value;
- (void)addCArrayMedicamentos:(NSSet *)values;
- (void)removeCArrayMedicamentos:(NSSet *)values;

- (void)addCArrayVacinasObject:(Vacina *)value;
- (void)removeCArrayVacinasObject:(Vacina *)value;
- (void)addCArrayVacinas:(NSSet *)values;
- (void)removeCArrayVacinas:(NSSet *)values;

- (void)addCArrayVermifugosObject:(Vermifugo *)value;
- (void)removeCArrayVermifugosObject:(Vermifugo *)value;
- (void)addCArrayVermifugos:(NSSet *)values;
- (void)removeCArrayVermifugos:(NSSet *)values;

- (void)addCArrayPesosObject:(Peso *)value;
- (void)removeCArrayPesosObject:(Peso *)value;
- (void)addCArrayPesos:(NSSet *)values;
- (void)removeCArrayPesos:(NSSet *)values;

@end
