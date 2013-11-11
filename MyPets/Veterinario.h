//
//  Veterinario.h
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Medicamento;

@interface Veterinario : NSManagedObject

@property (nonatomic, retain) NSString * cEmail;
@property (nonatomic, retain) NSString * cEndereco;
@property (nonatomic, retain) NSString * cEspecializacao;
@property (nonatomic, retain) NSString * cNome;
@property (nonatomic, retain) NSString * cObs;
@property (nonatomic, retain) NSString * cTelefone;
@property (nonatomic, retain) NSSet *cArrayMedicamentos;
@end

@interface Veterinario (CoreDataGeneratedAccessors)

- (void)addCArrayMedicamentosObject:(Medicamento *)value;
- (void)removeCArrayMedicamentosObject:(Medicamento *)value;
- (void)addCArrayMedicamentos:(NSSet *)values;
- (void)removeCArrayMedicamentos:(NSSet *)values;

@end
