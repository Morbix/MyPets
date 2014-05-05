//
//  MPCoreDataService.h
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#define MTPSNotificationPets @"br.com.alltouch.mypets.notification.pets"
#define MTPSNotificationPetsVacinas @"br.com.alltouch.mypets.notification.vacinas"
#define MTPSNotificationPetsVermifugos @"br.com.alltouch.mypets.notification.vermifugos"
#define MTPSNotificationPetsConsultas @"br.com.alltouch.mypets.notification.consultas"
#define MTPSNotificationPetsBanhos @"br.com.alltouch.mypets.notification.banhos"
#define MTPSNotificationPetsMedicamentos @"br.com.alltouch.mypets.notification.medicamentos"
#define MTPSNotificationPetsPesos @"br.com.alltouch.mypets.notification.pesos"

#import <Foundation/Foundation.h>
#import "Animal.h"
#import "Vacina.h"
#import "Vermifugo.h"
#import "Banho.h"
#import "Consulta.h"
#import "Medicamento.h"
#import "Peso.h"

@interface MPCoreDataService : NSObject

@property (nonatomic, strong) NSMutableArray *arrayPets;
@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) Animal *animalSelected;
@property (nonatomic, strong) Vacina *vacinaSelected;
@property (nonatomic, strong) Vermifugo *vermifugoSelected;
@property (nonatomic, strong) Consulta *consultaSelected;
@property (nonatomic, strong) Banho *banhoSelected;
@property (nonatomic, strong) Medicamento *medicamentoSelected;
@property (nonatomic, strong) Peso *pesoSelected;
@property (nonatomic, strong) UIImage *photoSelected;

+ (id)shared;
+ (void)saveContext;
- (void)loadAllPets;
- (int)numberOfPets;

#pragma mark - Animal
- (Animal *)newAnimal;
- (void)deleteAnimalSelected;

#pragma mark - Vacinas
- (Vacina *)newVacinaToAnimal:(Animal *)animal;
- (void)deleteVacinaSelected;

#pragma mark - Vermifugo
- (Vermifugo *)newVermifugoToAnimal:(Animal *)animal;
- (void)deleteVermifugoSelected;

#pragma mark - Consulta
- (Consulta *)newConsultaToAnimal:(Animal *)animal;
- (void)deleteConsultaSelected;

#pragma mark - Banho
- (Banho *)newBanhoToAnimal:(Animal *)animal;
- (void)deleteBanhoSelected;

#pragma mark - Medicamento
- (Medicamento *)newMedicamentoToAnimal:(Animal *)animal;
- (void)deleteMedicamentoSelected;

#pragma mark - Peso
- (Peso *)newPesoToAnimal:(Animal *)animal;
- (void)deletePesoSelected;

@end
