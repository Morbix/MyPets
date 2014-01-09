//
//  MPCoreDataService.m
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPCoreDataService.h"
#import "MPAppDelegate.h"
#import "MPLembretes.h"
#import "MPLibrary.h"

@implementation MPCoreDataService

+ (id)shared
{
    static MPCoreDataService *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPCoreDataService new];
        manager.arrayPets = [NSMutableArray new];
        manager.context = [(MPAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
#warning pendencia
        // nao salvar foto padrao nas vacinas e vermifugos
        //Ok - limpar sem animal
        //Ok - redimensionar fotos na entrada
        // redimensionar fotos ao salvar
        
        [manager fixCleanWithoutAnimal];
        [manager fixResizePhotos];
        //[manager loadAll1];
        //[manager loadAll2];
    });
    
    return manager;
}

+ (void)saveContext
{
    [[MPCoreDataService shared] save];
}

- (void)save
{
    NSError *error = nil;
    [self.context save:&error];
    
    if (error) {
        SHOW_ERROR(error.description);
    }
}

- (void)fixCleanWithoutAnimal
{
    NSArray *arrayEntidades = @[@"Banho", @"Medicamento", @"Consulta", @"Vacina", @"Vermifugo"];
    BOOL save = FALSE;
    
    for (NSString *entidade in arrayEntidades) {
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entidade inManagedObjectContext:self.context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(cAnimal = NIL)"];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *arrayResult = [self.context executeFetchRequest:request error:&error];
        if (!error){
            if (arrayResult.count > 0) {
                NSLog(@"---- Fix_without_cAnimal: N. %@: %d",entidade, arrayResult.count);
                for (NSManagedObject *object in arrayResult) {
                    [self.context deleteObject:object]; save = TRUE;
                }
            }
        }
    }
    
    if (save) {
        [self save];
    }
}

- (void)fixResizePhotos
{
    NSArray *arrayEntidades = @[@"Animal", @"Vacina", @"Vermifugo"];
    BOOL save = FALSE;
    
    for (NSString *entidade in arrayEntidades) {
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entidade inManagedObjectContext:self.context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        if ([entidade isEqualToString:@"Animal"]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(cFoto != NIL) AND (cFoto_Edited = NIL)"];
            [request setPredicate:predicate];
        }else{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(cSelo != NIL) AND (cFoto_Edited = NIL)"];
            [request setPredicate:predicate];
        }
        
        NSError *error;
        NSArray *arrayResult = [self.context executeFetchRequest:request error:&error];
        if (!error){
            if (arrayResult.count > 0) {
                int edited = 0;
                for (NSManagedObject *object in arrayResult) {
                    if ([object isKindOfClass:[Animal class]]) {
                        NSData * foto = [(Animal *)object cFoto];
                        
                        UIImage*image = [UIImage imageWithData:foto];
                        if (image.size.width > 320) {
                            UIImage *newImage = [MPLibrary imageWithoutCutsWithImage:image widthBased:320];
                            [(Animal *)object setCFoto:UIImagePNGRepresentation(newImage)];
                            [(Animal *)object setCFoto_Edited:[NSNumber numberWithBool:YES]];
                            save = TRUE; edited++;
                        }
                    }else if ([object isKindOfClass:[Vacina class]]) {
                        NSData * foto = [(Vacina *)object cSelo];
                        
                        UIImage*image = [UIImage imageWithData:foto];
                        if (image.size.width > 320) {
                            UIImage *newImage = [MPLibrary imageWithoutCutsWithImage:image widthBased:320];
                            [(Vacina *)object setCSelo:UIImagePNGRepresentation(newImage)];
                            [(Vacina *)object setCFoto_Edited:[NSNumber numberWithBool:YES]];
                            save = TRUE; edited++;
                        }
                    }else if ([object isKindOfClass:[Vermifugo class]]) {
                        NSData * foto = [(Vermifugo *)object cSelo];
                        
                        UIImage*image = [UIImage imageWithData:foto];
                        if (image.size.width > 320) {
                            UIImage *newImage = [MPLibrary imageWithoutCutsWithImage:image widthBased:320];
                            [(Vermifugo *)object setCSelo:UIImagePNGRepresentation(newImage)];
                            [(Vermifugo *)object setCFoto_Edited:[NSNumber numberWithBool:YES]];
                            save = TRUE; edited++;
                        }
                    }
                }
                if (edited > 0) {
                    NSLog(@"---- Fix_ResizePhoto:  N. %@: %d",entidade, edited);
                }
            }
        }
    }
    
    if (save) {
        [self save];
    }
}

- (void)loadAll2
{
    NSArray *arrayEntidades = @[@"Configuracao", @"Fotos", @"PetShop", @"Veterinario"];
    
    for (NSString *entidade in arrayEntidades) {
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entidade inManagedObjectContext:self.context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cAnimal = NIL"];
        //[request setPredicate:predicate];
        NSError *error;
        NSArray *arrayResult = [self.context executeFetchRequest:request error:&error];
        if (!error){
            NSLog(@"----- N. %@: %d",entidade, arrayResult.count);
        }
    }
}

- (void)loadAllPets
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Animal" inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *arrayResult = [self.context executeFetchRequest:request error:&error];
    if (arrayResult) {
        [self.arrayPets removeAllObjects];
        for (int i = 0; i < 1; i++) {
            for (Animal *animal in arrayResult) {
                [self.arrayPets addObject:animal];
            }
        }
    }
    
    NSLog(@"MPCoreDataService:buscarPets:%d - Completed", self.arrayPets.count);
    [[NSNotificationCenter defaultCenter] postNotificationName:MTPSNotificationPets object:nil userInfo:error ? [NSDictionary dictionaryWithObjectsAndKeys:error,@"error", nil] : nil];
}

#pragma mark - Animal
- (Animal *)newAnimal
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Animal" inManagedObjectContext:self.context];
    
    Animal *newAnimal = [[Animal alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.context];
    
    newAnimal.cNome    = NSLS(@"Pet");
    newAnimal.cEspecie = NSLS(@"Canino");
    newAnimal.cRaca    = @"";
    newAnimal.cSexo    = NSLS(@"Macho");
    newAnimal.cDataNascimento = [NSDate date];
    newAnimal.cObs            = @"";
    newAnimal.cFoto           = UIImageJPEGRepresentation([UIImage imageNamed:@"fotoDefault.png"], 1.0);
    newAnimal.cNeedUpdate     = [NSNumber numberWithBool:NO];
    
    NSError *error = nil;
    [self.context save:&error];
    
    [self loadAllPets];
    
    if (!error) {
        return newAnimal;
    }else{
        SHOW_ERROR(error.description);
        return nil;
    }
}

- (void)deleteAnimalSelected
{
    [[MPLembretes shared] deleteNotificationFromPet:self.animalSelected];
    
    for (Vacina* object in self.animalSelected.cArrayVacinas) {
        [self.context delete:object];
    }
    for (Vermifugo* object in self.animalSelected.cArrayVermifugos) {
        [self.context deleteObject:object];
    }
    for (Consulta* object in self.animalSelected.cArrayConsultas) {
        [self.context deleteObject:object];
    }
    for (Banho* object in self.animalSelected.cArrayBanhos) {
        [self.context deleteObject:object];
    }
    for (Medicamento* object in self.animalSelected.cArrayMedicamentos) {
        [self.context deleteObject:object];
    }
    for (Peso* object in self.animalSelected.cArrayPesos) {
        [self.context deleteObject:object];
    }
    
    [self.context deleteObject:self.animalSelected];
    [self.arrayPets removeObject:self.animalSelected];
    
    [self save];
    
    self.animalSelected = nil;
    
    NSLog(@"MPCoreDataService:buscarPets:%d - Completed", self.arrayPets.count);
    [[NSNotificationCenter defaultCenter] postNotificationName:MTPSNotificationPets object:nil userInfo:nil];
}

#pragma mark - Vacinas
- (Vacina *)newVacinaToAnimal:(Animal *)animal
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Vacina" inManagedObjectContext:self.context];
    
    Vacina * vac = [[Vacina alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.context];
    vac.cData       = nil;
    vac.cDataVacina = [NSDate date];
    vac.cAnimal     = animal;
    vac.cLembrete   = NSLS(@"Nunca");
    vac.cID         = [vac.objectID description];
    
    
    NSError *error = nil;
    [self.context save:&error];
    
    if (!error) {
        NSLog(@"MPCoreDataService:buscarVacinas:%d - Completed", animal.cArrayVacinas.count);
        [[NSNotificationCenter defaultCenter] postNotificationName:MTPSNotificationPetsVacinas object:nil userInfo:nil];
        
        return vac;
    }else{
        SHOW_ERROR(error.description);
        return nil;
    }
}

- (void)deleteVacinaSelected
{
    [[MPLembretes shared] deleteNotificationFromObject:self.vacinaSelected];
    
    [self.animalSelected removeCArrayVacinasObject:self.vacinaSelected];
    [self.context deleteObject:self.vacinaSelected];
    
    [self save];
    
    self.vacinaSelected = nil;
}

#pragma mark - Vermifugo
- (Vermifugo *)newVermifugoToAnimal:(Animal *)animal
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Vermifugo" inManagedObjectContext:self.context];
    
    
    Vermifugo * vermi = [[Vermifugo alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.context];
    vermi.cData       = nil;
    vermi.cDataVacina = [NSDate date];
    vermi.cAnimal     = animal;
    vermi.cLembrete   = NSLS(@"Nunca");
    vermi.cID         = [vermi.objectID description];
    
    
    NSError *error = nil;
    [self.context save:&error];
    
    if (!error) {
        NSLog(@"MPCoreDataService:buscarVermifugos:%d - Completed", animal.cArrayVermifugos.count);
        [[NSNotificationCenter defaultCenter] postNotificationName:MTPSNotificationPetsVermifugos object:nil userInfo:nil];
        
        return vermi;
    }else{
        SHOW_ERROR(error.description);
        return nil;
    }
}

- (void)deleteVermifugoSelected
{
    [[MPLembretes shared] deleteNotificationFromObject:self.vermifugoSelected];
    
    [self.animalSelected removeCArrayVermifugosObject:self.vermifugoSelected];
    [self.context deleteObject:self.vermifugoSelected];
    
    [self save];
    
    self.vermifugoSelected = nil;
}

#pragma mark - Consulta
- (Consulta *)newConsultaToAnimal:(Animal *)animal
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Consulta" inManagedObjectContext:self.context];
    
    Consulta * consulta = [[Consulta alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.context];
    consulta.cData       = nil;
    consulta.cAnimal     = animal;
    consulta.cLembrete   = NSLS(@"Nunca");
    consulta.cID         = [consulta.objectID description];
    consulta.cHorario    = nil;
    
    
    NSError *error = nil;
    [self.context save:&error];
    
    if (!error) {
        NSLog(@"MPCoreDataService:buscarConsultas:%d - Completed", animal.cArrayConsultas.count);
        [[NSNotificationCenter defaultCenter] postNotificationName:MTPSNotificationPetsConsultas object:nil userInfo:nil];
        
        return consulta;
    }else{
        SHOW_ERROR(error.description);
        return nil;
    }
}

- (void)deleteConsultaSelected
{
    [[MPLembretes shared] deleteNotificationFromObject:self.consultaSelected];
    
    [self.animalSelected removeCArrayConsultasObject:self.consultaSelected];
    [self.context deleteObject:self.consultaSelected];
    
    [self save];
    
    self.consultaSelected = nil;
}

#pragma mark - Banho
- (Banho *)newBanhoToAnimal:(Animal *)animal
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Banho" inManagedObjectContext:self.context];
    
    Banho * banho = [[Banho alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.context];
    banho.cData       = nil;
    banho.cPeso       = @0.0f;
    banho.cAnimal     = animal;
    banho.cLembrete   = NSLS(@"Nunca");
    banho.cID         = [banho.objectID description];
    banho.cHorario    = nil;
    
    
    NSError *error = nil;
    [self.context save:&error];
    
    if (!error) {
        NSLog(@"MPCoreDataService:buscarBanhos:%d - Completed", animal.cArrayBanhos.count);
        [[NSNotificationCenter defaultCenter] postNotificationName:MTPSNotificationPetsBanhos object:nil userInfo:nil];
        
        return banho;
    }else{
        SHOW_ERROR(error.description);
        return nil;
    }
}

- (void)deleteBanhoSelected
{
    [[MPLembretes shared] deleteNotificationFromObject:self.banhoSelected];
    
    [self.animalSelected removeCArrayBanhosObject:self.banhoSelected];
    [self.context deleteObject:self.banhoSelected];
    
    [self save];
    
    self.banhoSelected = nil;
}

#pragma mark - Medicamento
- (Medicamento *)newMedicamentoToAnimal:(Animal *)animal
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Medicamento" inManagedObjectContext:self.context];
    
    Medicamento * medicamento = [[Medicamento alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.context];
    medicamento.cNome = NSLS(@"Medicamento");
    medicamento.cDose = @"";
    medicamento.cData = nil;
    medicamento.cTipo = @"";
    medicamento.cPeso = @0.0f;
    medicamento.cAnimal     = animal;
    medicamento.cLembrete   = NSLS(@"Nunca");
    medicamento.cID         = [medicamento.objectID description];
    medicamento.cHorario    = nil;
    
    
    NSError *error = nil;
    [self.context save:&error];
    
    if (!error) {
        NSLog(@"MPCoreDataService:buscarMedicamentos:%d - Completed", animal.cArrayMedicamentos.count);
        [[NSNotificationCenter defaultCenter] postNotificationName:MTPSNotificationPetsMedicamentos object:nil userInfo:nil];
        
        return medicamento;
    }else{
        SHOW_ERROR(error.description);
        return nil;
    }
}

- (void)deleteMedicamentoSelected
{
    [[MPLembretes shared] deleteNotificationFromObject:self.medicamentoSelected];
    
    [self.animalSelected removeCArrayMedicamentosObject:self.medicamentoSelected];
    [self.context deleteObject:self.medicamentoSelected];
    
    [self save];
    
    self.medicamentoSelected = nil;
}
@end
