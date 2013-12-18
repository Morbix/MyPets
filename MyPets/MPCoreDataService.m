//
//  MPCoreDataService.m
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPCoreDataService.h"
#import "MPAppDelegate.h"


@implementation MPCoreDataService

+ (id)shared
{
    static MPCoreDataService *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPCoreDataService new];
        manager.arrayPets = [NSMutableArray new];
        manager.context = [(MPAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
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
@end
