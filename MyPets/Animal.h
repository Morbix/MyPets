//
//  Animal.h
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Banho, Consulta, Fotos, Medicamento, Vacina, Vermifugo;

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
@property (nonatomic, retain) NSString * cNome;
@property (nonatomic, retain) NSString * cObs;
@property (nonatomic, retain) NSString * cRaca;
@property (nonatomic, retain) NSString * cSexo;
@property (nonatomic, retain) NSSet *cArrayBanhos;
@property (nonatomic, retain) NSSet *cArrayConsultas;
@property (nonatomic, retain) NSSet *cArrayFotos;
@property (nonatomic, retain) NSSet *cArrayMedicamentos;
@property (nonatomic, retain) NSSet *cArrayVacinas;
@property (nonatomic, retain) NSSet *cArrayVermifugos;

- (UIImage *)getFoto;
- (NSString *)getNome;

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

@end
