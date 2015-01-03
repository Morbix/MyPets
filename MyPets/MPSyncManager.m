//
//  MPSyncManager.m
//  MyPets
//
//  Created by Henrique Morbin on 30/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPSyncManager.h"

#import "MPInternetManager.h"
#import "MPAppDelegate.h"
#import "FCFileManager.h"
#import "MPReminderManager.h"
#import "Sync.h"

#import "Animal.h"
#import "PFAnimal.h"

#import "Banho.h"
#import "PFBath.h"

#import "Consulta.h"
#import "PFAppointment.h"

#import "Medicamento.h"
#import "PFMedice.h"

#import "Peso.h"
#import "PFWeight.h"

#import "Vacina.h"
#import "PFVaccine.h"

#import "Vermifugo.h"
#import "PFVermifuge.h"

@interface MPSyncManager ()

@end

@implementation MPSyncManager

+ (instancetype)shared
{
    static MPSyncManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPSyncManager new];
        
        manager.syncronizationStatus = MPSyncStatusNone;
        
        manager.context = [(MPAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        manager.syncDates = [manager getSyncDates];
        
        [manager addObserver:manager forKeyPath:NSStringFromSelector(@selector(syncronizationStatus))
                     options:NSKeyValueObservingOptionNew
                     context:nil];
        
        [NSTimer scheduledTimerWithTimeInterval:30 target:manager selector:@selector(startSyncronization) userInfo:nil repeats:YES];
    });
    return manager;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(migrationStatus))];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(migrationStatus))]) {
        if ([self.delegate respondsToSelector:@selector(migration:didChangeStatus:)]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.delegate sync:self didChangeStatus:self.syncronizationStatus];
            });
        }
    }
}

#pragma mark - Syncronization
- (void)startSyncronization
{
    if (self.syncronizationStatus != MPSyncStatusInProgress) {
        
        self.syncronizationStatus = MPSyncStatusInProgress;
        
        if ([[MPInternetManager shared] hasInternetConnection] && [PFUser currentUser]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if ([self startSyncWithThreadSafe]) {
                    self.syncronizationStatus = MPSyncStatusDone;
                }else{
                    self.syncronizationStatus = MPSyncStatusStopped;
                }
            });
        }else{
            self.syncronizationStatus = MPSyncStatusCancelled;
        }
    }else{
        if (MX_DESENV_MODE) {
            NSLog(@"%s Sync in progress...", __PRETTY_FUNCTION__);
        }
    }
}

- (BOOL)startSyncWithThreadSafe
{
    if (MX_DESENV_MODE) {
        NSLog(@"%s Starting Migration...", __PRETTY_FUNCTION__);
    }
    
    BOOL completed = YES;
    
    NSArray *arrayClasses = @[
                              @{@"entityName": @"Animal",      @"class": [PFAnimal class],      @"fieldName": @"classAnimal"},
                              @{@"entityName": @"Vacina",      @"class": [PFVaccine class],     @"fieldName": @"classVaccine"},
                              @{@"entityName": @"Vermifugo",   @"class": [PFVermifuge class],   @"fieldName": @"classVermifuge"},
                              @{@"entityName": @"Medicamento", @"class": [PFMedice class],      @"fieldName": @"classMedicine"},
                              @{@"entityName": @"Consulta",    @"class": [PFAppointment class], @"fieldName": @"classAppointment"},
                              @{@"entityName": @"Banho",       @"class": [PFBath class],        @"fieldName": @"classBath"},
                              @{@"entityName": @"Peso",        @"class": [PFWeight class],      @"fieldName": @"classWeight"},
                            ];
    
    
    for (NSDictionary *dict in arrayClasses) {
        completed = [self syncEntityName:dict[@"entityName"] andClass:dict[@"class"] fieldName:dict[@"fieldName"]];
        if (!completed) { break;}
        
        
    }
    
    if (MX_DESENV_MODE) {
        if (completed) {
            NSLog(@"%s ###Finishing### Migration...", __PRETTY_FUNCTION__);
        }else{
            NSLog(@"%s ###Stoping### Migration...", __PRETTY_FUNCTION__);
        }
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n\n\n");
    }
    
    return completed;
}

- (BOOL)syncEntityName:(NSString *)entityName andClass:(Class)class fieldName:(NSString *)fieldNameForLastUpdatedDate
{
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting sync for: %@", __PRETTY_FUNCTION__, entityName);
    }
    
    BOOL completed = YES;
    
    NSDate *dateLastUpdate = [self.syncDates valueForKey:fieldNameForLastUpdatedDate];
    completed = dateLastUpdate ? YES : NO;
    if (!completed) { return completed;}
    if (MX_DESENV_MODE) {
        NSLog(@"%s date last update %@", __PRETTY_FUNCTION__, dateLastUpdate);
    }

    NSArray *arrayCoreDataObjects = [self getAllObjectsWithEntityName:entityName andLastUpdateNilOfGreaterThan:dateLastUpdate];
    completed = arrayCoreDataObjects ? YES : NO;
    if (!completed) { return completed;}
    if (MX_DESENV_MODE) {
        NSLog(@"%s number of entity: %@ need sync: %d", __PRETTY_FUNCTION__, entityName, (int)arrayCoreDataObjects.count);
    }
    
    NSArray *arrayParseObjects = [self getAllObjectsWithClass:class andLastUpdateNilOfGreaterThan:dateLastUpdate];
    completed = arrayParseObjects ? YES : NO;
    if (!completed) { return completed;}
    if (MX_DESENV_MODE) {
        NSLog(@"%s number of class: %@ need sync: %d", __PRETTY_FUNCTION__, NSStringFromClass(class), (int)arrayParseObjects.count);
    }
    
    if ((arrayCoreDataObjects.count+arrayParseObjects.count) > 0) {
        
        for (NSManagedObject *coreDataObject in arrayCoreDataObjects) {
            if ([self canSyncCoreData:coreDataObject arrayParse:arrayParseObjects]) {
                //sync core data object
                completed = [self syncObject:coreDataObject forEntityName:entityName];
                if (!completed) { return completed;}
            }
        }
        
        for (PFObject *parseObject in arrayParseObjects) {
            if ([self canSyncParse:parseObject arrayCoreData:arrayCoreDataObjects]) {
                //sync parse object
                completed = [self syncObject:parseObject forClassName:NSStringFromClass(class)];
                if (!completed) { return completed;}
            }
        }
    }
    
    __block NSError *error = nil;
    
    [self.syncDates setValue:[NSDate date] forKey:fieldNameForLastUpdatedDate];
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        [self.context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    return completed;
}

- (BOOL)syncObject:(NSManagedObject *)object forEntityName:(NSString *)entityName
{
    if ([entityName isEqualToString:@"Animal"]) {
        return [self _syncCoreDataAnimal:(Animal *)object];
    }else if ([entityName isEqualToString:@"Vacina"]) {
        return [self _syncCoreDataGenericObject:object
                                  andParseClass:[PFVaccine class]
                                     andLogName:NSStringFromClass([Vacina class])
                                andRelationName:@"relationOfVaccine"
                                  andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Vacina class]), [[(Vacina *)object cAnimal] cNome]]
                                  andPhotoField:@"cSelo"
                                       andBlock:^(PFVaccine *__autoreleasing *_objectToSave, Vacina *__autoreleasing *_objectToMigrate, PFAnimal *animalRelated) {
                                           PFVaccine * objectToSave = *_objectToSave;
                                           Vacina * objectToMigrate = *_objectToMigrate;
                                           
                                           [objectToSave setAnimal:animalRelated];
                                           [objectToSave setOwner:[PFUser currentUser]];
                                           
                                           if (objectToMigrate.cData) {
                                               [objectToSave setDateAndTime:objectToMigrate.cData];
                                           }
                                           if (objectToMigrate.cDataVacina) {
                                               [objectToSave setDateAndTimeVaccine:objectToMigrate.cDataVacina];
                                           }
                                           if (objectToMigrate.cID) {
                                               [objectToSave setVaccineId:objectToMigrate.cID];
                                           }
                                           if (objectToMigrate.cLembrete) {
                                               [objectToSave setReminder:[MPReminderManager translateReminderStringToInt:objectToMigrate.cLembrete]];
                                           }
                                           if (objectToMigrate.cObs) {
                                               [objectToSave setNotes:objectToMigrate.cObs];
                                           }
                                           if (objectToMigrate.cPeso) {
                                               [objectToSave setWeight:objectToMigrate.cPeso];
                                           }
                                           if (objectToMigrate.cDose) {
                                               [objectToSave setDose:objectToMigrate.cDose];
                                           }
                                           if (objectToMigrate.cVeterinario) {
                                               [objectToSave setVeterinarian:objectToMigrate.cVeterinario];
                                           }
                                       }];
    }else if ([entityName isEqualToString:@"Vermifugo"]) {
        return [self _syncCoreDataGenericObject:object
                                  andParseClass:[PFVermifuge class]
                                     andLogName:NSStringFromClass([Vermifugo class])
                                andRelationName:@"relationOfVermifuge"
                                  andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Vermifugo class]), [[(Vermifugo *)object cAnimal] cNome]]
                                  andPhotoField:@"cSelo"
                                       andBlock:^(PFVermifuge *__autoreleasing *_objectToSave, Vermifugo *__autoreleasing *_objectToMigrate, PFAnimal *animalRelated) {
                                           PFVermifuge * objectToSave = *_objectToSave;
                                           Vermifugo * objectToMigrate = *_objectToMigrate;
                                           
                                           [objectToSave setAnimal:animalRelated];
                                           [objectToSave setOwner:[PFUser currentUser]];
                                           
                                           if (objectToMigrate.cData) {
                                               [objectToSave setDateAndTime:objectToMigrate.cData];
                                           }
                                           if (objectToMigrate.cDataVacina) {
                                               [objectToSave setDateAndTimeVaccine:objectToMigrate.cDataVacina];
                                           }
                                           if (objectToMigrate.cID) {
                                               [objectToSave setVermifugeId:objectToMigrate.cID];
                                           }
                                           if (objectToMigrate.cLembrete) {
                                               [objectToSave setReminder:[MPReminderManager translateReminderStringToInt:objectToMigrate.cLembrete]];
                                           }
                                           if (objectToMigrate.cObs) {
                                               [objectToSave setNotes:objectToMigrate.cObs];
                                           }
                                           if (objectToMigrate.cPeso) {
                                               [objectToSave setWeight:objectToMigrate.cPeso];
                                           }
                                           if (objectToMigrate.cDose) {
                                               [objectToSave setDose:objectToMigrate.cDose];
                                           }
                                       }];
    }else if ([entityName isEqualToString:@"Medicamento"]) {
        return [self _syncCoreDataGenericObject:object
                                  andParseClass:[PFMedice class]
                                     andLogName:NSStringFromClass([Medicamento class])
                                andRelationName:@"relationOfMedicine"
                                  andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Medicamento class]), [[(Medicamento *)object cAnimal] cNome]]
                                  andPhotoField:nil
                                       andBlock:^(PFMedice *__autoreleasing *_objectToSave, Medicamento *__autoreleasing *_objectToMigrate, PFAnimal *animalRelated) {
                                           PFMedice * medicineToSave = *_objectToSave;
                                           Medicamento * medicineToMigrate = *_objectToMigrate;
                                           
                                           [medicineToSave setAnimal:animalRelated];
                                           [medicineToSave setOwner:[PFUser currentUser]];
                                           
                                           if (medicineToMigrate.cData) {
                                               if (medicineToMigrate.cHorario) {
                                                   [medicineToSave setDateAndTime:[self combineDate:medicineToMigrate.cData
                                                                                           withTime:medicineToMigrate.cHorario]];
                                               }else{
                                                   [medicineToSave setDateAndTime:medicineToMigrate.cData];
                                               }
                                           }
                                           if (medicineToMigrate.cID) {
                                               [medicineToSave setMediceId:medicineToMigrate.cID];
                                           }
                                           if (medicineToMigrate.cLembrete) {
                                               [medicineToSave setReminder:[MPReminderManager translateReminderStringToInt:medicineToMigrate.cLembrete]];
                                           }
                                           if (medicineToMigrate.cObs) {
                                               [medicineToSave setNotes:medicineToMigrate.cObs];
                                           }
                                           if (medicineToMigrate.cPeso) {
                                               [medicineToSave setWeight:medicineToMigrate.cPeso.floatValue];
                                           }
                                           if (medicineToMigrate.cDose) {
                                               [medicineToSave setDose:medicineToMigrate.cDose];
                                           }
                                           if (medicineToMigrate.cNome) {
                                               [medicineToSave setName:medicineToMigrate.cNome];
                                           }
                                           if (medicineToMigrate.cTipo) {
                                               [medicineToSave setType:medicineToMigrate.cTipo];
                                           }
                                       }];
    }else if ([entityName isEqualToString:@"Consulta"]) {
        return [self _syncCoreDataGenericObject:object
                                  andParseClass:[PFAppointment class]
                                     andLogName:NSStringFromClass([Consulta class])
                                andRelationName:@"relationOfAppointment"
                                  andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Consulta class]), [[(Consulta *)object cAnimal] cNome]]
                                  andPhotoField:nil
                                       andBlock:^(PFAppointment *__autoreleasing *_objectToSave, Consulta *__autoreleasing *_objectToMigrate, PFAnimal *animalRelated) {
                                           PFAppointment * appointmentToSave = *_objectToSave;
                                           Consulta * appointmentToMigrate = *_objectToMigrate;
                                           
                                           [appointmentToSave setAnimal:animalRelated];
                                           [appointmentToSave setOwner:[PFUser currentUser]];
                                           
                                           if (appointmentToMigrate.cData) {
                                               if (appointmentToMigrate.cHorario) {
                                                   [appointmentToSave setDateAndTime:[self combineDate:appointmentToMigrate.cData
                                                                                              withTime:appointmentToMigrate.cHorario]];
                                               }else{
                                                   [appointmentToSave setDateAndTime:appointmentToMigrate.cData];
                                               }
                                           }
                                           if (appointmentToMigrate.cID) {
                                               [appointmentToSave setAppointmentId:appointmentToMigrate.cID];
                                           }
                                           if (appointmentToMigrate.cLembrete) {
                                               [appointmentToSave setReminder:[MPReminderManager translateReminderStringToInt:appointmentToMigrate.cLembrete]];
                                           }
                                           if (appointmentToMigrate.cObs) {
                                               [appointmentToSave setNotes:appointmentToMigrate.cObs];
                                           }
                                       }];
    }else if ([entityName isEqualToString:@"Banho"]) {
        return [self _syncCoreDataGenericObject:object
                                  andParseClass:[PFBath class]
                                     andLogName:NSStringFromClass([Banho class])
                                andRelationName:@"relationOfBath"
                                  andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Banho class]), [[(Banho *)object cAnimal] cNome]]
                                  andPhotoField:nil
                                       andBlock:^(PFBath *__autoreleasing *_objectToSave, Banho *__autoreleasing *_objectToMigrate, PFAnimal *animalRelated) {
                                           PFBath * bathToSave = *_objectToSave;
                                           Banho * bathToMigrate = *_objectToMigrate;
                                           
                                           [bathToSave setAnimal:animalRelated];
                                           [bathToSave setOwner:[PFUser currentUser]];
                                           
                                           if (bathToMigrate.cData) {
                                               if (bathToMigrate.cHorario) {
                                                   [bathToSave setDateAndTime:[self combineDate:bathToMigrate.cData
                                                                                       withTime:bathToMigrate.cHorario]];
                                               }else{
                                                   [bathToSave setDateAndTime:bathToMigrate.cData];
                                               }
                                           }
                                           if (bathToMigrate.cID) {
                                               [bathToSave setBathId:bathToMigrate.cID];
                                           }
                                           if (bathToMigrate.cLembrete) {
                                               [bathToSave setReminder:[MPReminderManager translateReminderStringToInt:bathToMigrate.cLembrete]];
                                           }
                                           if (bathToMigrate.cObs) {
                                               [bathToSave setNotes:bathToMigrate.cObs];
                                           }
                                           if (bathToMigrate.cPeso) {
                                               [bathToSave setWeight:bathToMigrate.cPeso.floatValue];
                                           }
                                       }];
    }else if ([entityName isEqualToString:@"Peso"]) {
        return [self _syncCoreDataGenericObject:object
                                  andParseClass:[PFWeight class]
                                     andLogName:NSStringFromClass([Peso class])
                                andRelationName:@"relationOfWeight"
                                  andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Peso class]), [[(Peso *)object cAnimal] cNome]]
                                  andPhotoField:nil
                                       andBlock:^(PFWeight *__autoreleasing *_objectToSave, Peso *__autoreleasing *_objectToMigrate, PFAnimal *animalRelated) {
                                           PFWeight * weightToSave = *_objectToSave;
                                           Peso * weightToMigrate = *_objectToMigrate;
                                           
                                           [weightToSave setAnimal:animalRelated];
                                           [weightToSave setOwner:[PFUser currentUser]];
                                           
                                           if (weightToMigrate.cData) {
                                               [weightToSave setDateAndTime:weightToMigrate.cData];
                                           }
                                           if (weightToMigrate.cID) {
                                               [weightToSave setWeightId:weightToMigrate.cID];
                                           }
                                           if (weightToMigrate.cObs) {
                                               [weightToSave setNotes:weightToMigrate.cObs];
                                           }
                                           if (weightToMigrate.cPeso) {
                                               [weightToSave setWeight:weightToMigrate.cPeso.floatValue];
                                           }
                                       }];
    }
    
    return YES;
}

- (BOOL)syncObject:(PFObject *)object forClassName:(NSString *)className
{
#warning UPDATE REMINDERS
#warning UPDATE UI
#warning DELETE DATA
#warning BUG, when data in server is modified and updatedAt is greater than local updatedAtReference
    
    BOOL complete = YES;
    if ([className isEqualToString:@"PFAnimal"]) {
        complete = [self _syncParseAnimal:(PFAnimal *)object];
        if (complete) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_UPDATE_ALL_ANIMALS object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_UPDATE_ANIMAL object:nil userInfo:@{@"objectId": object.objectId}];
        }
    }else if ([className isEqualToString:@"PFVaccine"]) {
        complete = [self _syncParseGenericObject:object
                           andCoreDataEntityName:NSStringFromClass([Vacina class])
                                   andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Vacina class]), object.objectId] andLogName:NSStringFromClass([Vacina class])
                                   andPhotoField:@"cSelo"
                                        andBlock:^(Vacina *__autoreleasing *_objectToSave, PFVaccine *__autoreleasing *_objectToMigrate, Animal *animalRelated) {
                                            Vacina *objectToSave = *_objectToSave;
                                            PFVaccine *objectToMigrate = *_objectToMigrate;
                                            
                                            objectToSave.cAnimal = animalRelated;
                                            if (objectToMigrate.dateAndTime) {
                                                [objectToSave setCData:objectToMigrate.dateAndTime];
                                            }
                                            if (objectToMigrate.dateAndTimeVaccine) {
                                                [objectToSave setCDataVacina:objectToMigrate.dateAndTimeVaccine];
                                            }
                                            if (objectToMigrate.vaccineId) {
                                                [objectToSave setCID:objectToMigrate.vaccineId];
                                            }
                                            if (objectToMigrate.reminder) {
                                                [objectToSave setCLembrete:[MPReminderManager translateReminderIntToStrig:objectToMigrate.reminder]];
                                            }
                                            if (objectToMigrate.notes) {
                                                [objectToSave setCObs:objectToMigrate.notes];
                                            }
                                            if (objectToMigrate.weight) {
                                                [objectToSave setCPeso:objectToMigrate.weight];
                                            }
                                            if (objectToMigrate.dose) {
                                                [objectToSave setCDose:objectToMigrate.dose];
                                            }
                                            if (objectToMigrate.veterinarian) {
                                                [objectToSave setCVeterinario:objectToMigrate.veterinarian];
                                            }
                                        }];
        if (complete) {

        }
    }else if ([className isEqualToString:@"PFVermifuge"]) {
        complete = [self _syncParseGenericObject:object
                           andCoreDataEntityName:NSStringFromClass([Vermifugo class])
                                   andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Vermifugo class]), object.objectId] andLogName:NSStringFromClass([Vermifugo class])
                                   andPhotoField:@"cSelo"
                                        andBlock:^(Vermifugo *__autoreleasing *_objectToSave, PFVermifuge *__autoreleasing *_objectToMigrate, Animal *animalRelated) {
                                            Vermifugo   *objectToSave = *_objectToSave;
                                            PFVermifuge *objectToMigrate = *_objectToMigrate;
                                            
                                            objectToSave.cAnimal = animalRelated;
                                            if (objectToMigrate.dateAndTime) {
                                                [objectToSave setCData:objectToMigrate.dateAndTime];
                                            }
                                            if (objectToMigrate.dateAndTimeVaccine) {
                                                [objectToSave setCDataVacina:objectToMigrate.dateAndTimeVaccine];
                                            }
                                            if (objectToMigrate.vermifugeId) {
                                                [objectToSave setCID:objectToMigrate.vermifugeId];
                                            }
                                            if (objectToMigrate.reminder) {
                                                [objectToSave setCLembrete:[MPReminderManager translateReminderIntToStrig:objectToMigrate.reminder]];
                                            }
                                            if (objectToMigrate.notes) {
                                                [objectToSave setCObs:objectToMigrate.notes];
                                            }
                                            if (objectToMigrate.weight) {
                                                [objectToSave setCPeso:objectToMigrate.weight];
                                            }
                                            if (objectToMigrate.dose) {
                                                [objectToSave setCDose:objectToMigrate.dose];
                                            }
                                        }];
        if (complete) {
            
        }
    }else if ([className isEqualToString:@"PFMedicine"]) {
        complete = [self _syncParseGenericObject:object
                           andCoreDataEntityName:NSStringFromClass([Medicamento class])
                                   andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Medicamento class]), object.objectId] andLogName:NSStringFromClass([Medicamento class])
                                   andPhotoField:nil
                                        andBlock:^(Medicamento *__autoreleasing *_objectToSave, PFMedice *__autoreleasing *_objectToMigrate, Animal *animalRelated) {
                                            Medicamento   *objectToSave = *_objectToSave;
                                            PFMedice *objectToMigrate = *_objectToMigrate;
                                            
                                            objectToSave.cAnimal = animalRelated;
                                            if (objectToMigrate.dateAndTime) {
                                                [objectToSave setCData:objectToMigrate.dateAndTime];
                                                [objectToSave setCHorario:objectToMigrate.dateAndTime];
                                            }
                                            if (objectToMigrate.mediceId) {
                                                [objectToSave setCID:objectToMigrate.mediceId];
                                            }
                                            if (objectToMigrate.reminder) {
                                                [objectToSave setCLembrete:[MPReminderManager translateReminderIntToStrig:objectToMigrate.reminder]];
                                            }
                                            if (objectToMigrate.notes) {
                                                [objectToSave setCObs:objectToMigrate.notes];
                                            }
                                            if (objectToMigrate.weight) {
                                                [objectToSave setCPeso:[NSNumber numberWithFloat:objectToMigrate.weight]];
                                            }
                                            if (objectToMigrate.dose) {
                                                [objectToSave setCDose:objectToMigrate.dose];
                                            }
                                            if (objectToMigrate.name) {
                                                [objectToSave setCNome:objectToMigrate.name];
                                            }
                                            if (objectToMigrate.type) {
                                                [objectToSave setCTipo:objectToMigrate.type];
                                            }
                                        }];
        if (complete) {
            
        }
    }else if ([className isEqualToString:@"PFAppointment"]) {
        complete = [self _syncParseGenericObject:object
                           andCoreDataEntityName:NSStringFromClass([Consulta class])
                                   andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Consulta class]), object.objectId] andLogName:NSStringFromClass([Consulta class])
                                   andPhotoField:nil
                                        andBlock:^(Consulta *__autoreleasing *_objectToSave, PFAppointment *__autoreleasing *_objectToMigrate, Animal *animalRelated) {
                                            Consulta   *objectToSave = *_objectToSave;
                                            PFAppointment *objectToMigrate = *_objectToMigrate;
                                            
                                            objectToSave.cAnimal = animalRelated;
                                            if (objectToMigrate.dateAndTime) {
                                                [objectToSave setCData:objectToMigrate.dateAndTime];
                                                [objectToSave setCHorario:objectToMigrate.dateAndTime];
                                            }
                                            if (objectToMigrate.appointmentId) {
                                                [objectToSave setCID:objectToMigrate.appointmentId];
                                            }
                                            if (objectToMigrate.reminder) {
                                                [objectToSave setCLembrete:[MPReminderManager translateReminderIntToStrig:objectToMigrate.reminder]];
                                            }
                                            if (objectToMigrate.notes) {
                                                [objectToSave setCObs:objectToMigrate.notes];
                                            }
                                        }];
        if (complete) {
            
        }
    }else if ([className isEqualToString:@"PFBath"]) {
        complete = [self _syncParseGenericObject:object
                           andCoreDataEntityName:NSStringFromClass([Banho class])
                                   andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Banho class]), object.objectId] andLogName:NSStringFromClass([Banho class])
                                   andPhotoField:nil
                                        andBlock:^(Banho *__autoreleasing *_objectToSave, PFBath *__autoreleasing *_objectToMigrate, Animal *animalRelated) {
                                            Banho   *objectToSave = *_objectToSave;
                                            PFBath *objectToMigrate = *_objectToMigrate;
                                            
                                            objectToSave.cAnimal = animalRelated;
                                            if (objectToMigrate.dateAndTime) {
                                                [objectToSave setCData:objectToMigrate.dateAndTime];
                                                [objectToSave setCHorario:objectToMigrate.dateAndTime];
                                            }
                                            if (objectToMigrate.bathId) {
                                                [objectToSave setCID:objectToMigrate.bathId];
                                            }
                                            if (objectToMigrate.reminder) {
                                                [objectToSave setCLembrete:[MPReminderManager translateReminderIntToStrig:objectToMigrate.reminder]];
                                            }
                                            if (objectToMigrate.notes) {
                                                [objectToSave setCObs:objectToMigrate.notes];
                                            }
                                            if (objectToMigrate.weight) {
                                                [objectToSave setCPeso:[NSNumber numberWithFloat:objectToMigrate.weight]];
                                            }
                                        }];
        if (complete) {
            
        }
    }else if ([className isEqualToString:@"PFWeight"]) {
        complete = [self _syncParseGenericObject:object
                           andCoreDataEntityName:NSStringFromClass([Peso class])
                                   andObjectName:[NSString stringWithFormat:@"%@(%@)", NSStringFromClass([Peso class]), object.objectId] andLogName:NSStringFromClass([Peso class])
                                   andPhotoField:nil
                                        andBlock:^(Peso *__autoreleasing *_objectToSave, PFWeight *__autoreleasing *_objectToMigrate, Animal *animalRelated) {
                                            Peso   *objectToSave = *_objectToSave;
                                            PFWeight *objectToMigrate = *_objectToMigrate;
                                            
                                            objectToSave.cAnimal = animalRelated;
                                            if (objectToMigrate.dateAndTime) {
                                                [objectToSave setCData:objectToMigrate.dateAndTime];
                                            }
                                            if (objectToMigrate.weightId) {
                                                [objectToSave setCID:objectToMigrate.weightId];
                                            }
                                            if (objectToMigrate.notes) {
                                                [objectToSave setCObs:objectToMigrate.notes];
                                            }
                                            if (objectToMigrate.weight) {
                                                [objectToSave setCPeso:[NSNumber numberWithFloat:objectToMigrate.weight]];
                                            }
                                        }];
        if (complete) {
            
        }
    }
    
    return complete;
}

- (BOOL)canSyncCoreData:(NSManagedObject *)object arrayParse:(NSArray *)arrayParse
{
    NSString *coreDataIdentifier = [object valueForKey:@"cIdentifier"];
    
    if (!coreDataIdentifier || [coreDataIdentifier isEqualToString:@""] || coreDataIdentifier.length > 15) {
        return YES;
    }
    
    NSDate *coreDataUpdatedAt = [object valueForKey:@"updatedAt"];
    
    if (!coreDataUpdatedAt) {
        coreDataUpdatedAt = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    for (PFObject *parseObject in arrayParse) {
        if ([parseObject.objectId isEqualToString:coreDataIdentifier]) {
            if (parseObject.updatedAt > coreDataUpdatedAt) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)canSyncParse:(PFObject *)object arrayCoreData:(NSArray *)arrayCoreData
{
    for (NSManagedObject *coreDataObject in arrayCoreData) {
        NSString *coreDataIdentifier = [coreDataObject valueForKey:@"cIdentifier"];
        if (!coreDataIdentifier || [coreDataIdentifier isEqualToString:@""] || coreDataIdentifier.length > 15) {
            continue;
        }else{
            if ([coreDataIdentifier isEqualToString:object.objectId]) {
                NSDate *coreDataUpdatedAt = [coreDataObject valueForKey:@"updatedAt"];
                
                if (!coreDataUpdatedAt) {
                    coreDataUpdatedAt = [NSDate dateWithTimeIntervalSince1970:0];
                }
                
                if (coreDataUpdatedAt > object.updatedAt) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - Sync Core Data Objects
- (BOOL)_syncCoreDataAnimal:(Animal *)animalToMigrate
{
    __block NSError *error = nil;
    
    PFAnimal *animalToSave = nil;
    
    NSString *animalName = animalToMigrate.cNome;

    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Core Data Animal: %@",animalName);
    }
    
    if (animalToMigrate.cIdentifier && ![animalToMigrate.cIdentifier isEqualToString:@""] && (animalToMigrate.cIdentifier.length < 15)) {
        animalToSave = [PFAnimal objectWithoutDataWithObjectId:animalToMigrate.cIdentifier];
    }else{
        animalToSave = [PFAnimal object];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting sync animal: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    
    [animalToSave setOwner:[PFUser currentUser]];
    
    if (animalToMigrate.cDataNascimento) {
        [animalToSave setBirthday:animalToMigrate.cDataNascimento];
    }
    if (animalToMigrate.cEspecie) {
        [animalToSave setSpecie:animalToMigrate.cEspecie];
    }
    if (animalToMigrate.cID) {
        [animalToSave setAnimalId:animalToMigrate.cID];
    }
    if (animalToMigrate.cNome) {
        [animalToSave setName:animalToMigrate.cNome];
    }
    if (animalToMigrate.cObs) {
        [animalToSave setNotes:animalToMigrate.cObs];
    }
    if (animalToMigrate.cRaca) {
        [animalToSave setBreed:animalToMigrate.cRaca];
    }
    if (animalToMigrate.cSexo) {
        [animalToSave setSex:animalToMigrate.cSexo];
    }
    
    
    if (animalToMigrate.cFoto) {

        if (MX_DESENV_MODE) {
            NSLog(@"%s sending photo", __PRETTY_FUNCTION__);
        }
        PFFile *filePhoto = [PFFile fileWithData:animalToMigrate.cFoto
                             contentType:@"image/png"];
        [filePhoto save:&error];
        if (error) {
            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
            return NO;
        }
        
        if (MX_DESENV_MODE) {
            NSLog(@"%s photo sent", __PRETTY_FUNCTION__);
        }
        
        [animalToSave setPhoto:filePhoto];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving animal: %@", __PRETTY_FUNCTION__ , animalName);
    }
    [animalToSave save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        if (error.code == 101) {
            error = nil;
            animalToMigrate.cIdentifier = @"";
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                [self.context save:&error];
            });
            if (error) {
                NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                return NO;
            }
        }
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    animalToMigrate.cIdentifier = [animalToSave objectId];
    animalToMigrate.updatedAt   = [animalToSave updatedAt];
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        [self.context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving relation between user and animal: %@", __PRETTY_FUNCTION__ , animalName);
    }
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"relationOfAnimal"];
    [relation addObject:animalToSave];
    [[PFUser currentUser] save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish sync animal: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return YES;
}

- (BOOL)_syncCoreDataGenericObject:(NSManagedObject *)objectToMigrate andParseClass:(Class <PFSubclassing>)class andLogName:(NSString *)logName andRelationName:(NSString *)relationName andObjectName:(NSString *)objectName andPhotoField:(NSString *)fieldPhoto andBlock:(void (^)(PFObject **objectToSave, NSManagedObject **objectToMigrate, PFAnimal *animalRelated))blockAttributes
{
    __block NSError *error = nil;
    
    PFObject *objectToSave = nil;

    PFAnimal *animalRelated = [PFAnimal objectWithoutDataWithObjectId:[[objectToMigrate valueForKey:@"cAnimal"] valueForKey:@"cIdentifier"]];
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Core Data %@: %@", logName, objectName);
    }
    
    NSString *identifier = [objectToMigrate valueForKey:@"cIdentifier"];
    
    if (identifier && ![identifier isEqualToString:@""] && (identifier.length < 15)) {
        objectToSave = [class objectWithoutDataWithObjectId:identifier ];
    }else{
        objectToSave = [class object];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting sync %@: %@", __PRETTY_FUNCTION__, logName, objectName);
    }
    
    blockAttributes(&objectToSave, &objectToMigrate, animalRelated);
    
    if (fieldPhoto) {
        if ([objectToMigrate valueForKey:fieldPhoto]) {
            if (MX_DESENV_MODE) {
                NSLog(@"%s sending photo", __PRETTY_FUNCTION__);
            }
            PFFile *filePhoto = [PFFile fileWithData:[objectToMigrate valueForKey:fieldPhoto]
                                         contentType:@"image/png"];
            [filePhoto save:&error];
            if (error) {
                NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                return NO;
            }
            
            if (MX_DESENV_MODE) {
                NSLog(@"%s photo sent", __PRETTY_FUNCTION__);
            }
            
            [objectToSave setValue:filePhoto forKey:@"photo"];
        }
    }
    
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving %@: %@", __PRETTY_FUNCTION__, logName, objectName);
    }
    [objectToSave save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        if (error.code == 101) {
            error = nil;
            [objectToMigrate setValue:@"" forKey:@"cIdentifier"];
            [objectToMigrate setValue:[NSDate dateWithTimeIntervalSinceNow:60] forKey:@"updatedAt"];
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                [self.context save:&error];
            });
            if (error) {
                NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                return NO;
            }
        }
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    [objectToMigrate setValue:[objectToSave objectId] forKey:@"cIdentifier"];
    [objectToMigrate setValue:[objectToSave updatedAt] forKey:@"updatedAt"];
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        [self.context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving relation between user and %@: %@", __PRETTY_FUNCTION__, logName, objectName);
    }
    PFRelation *relation = [animalRelated relationForKey:relationName];
    [relation addObject:objectToSave];
    [animalRelated save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish sync %@: %@", __PRETTY_FUNCTION__, logName, objectName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return YES;
}

#pragma mark - Sync Parse Objects
- (BOOL)_syncParseAnimal:(PFAnimal *)animalToMigrate
{
    __block NSError *error = nil;
    
    NSString *animalName = animalToMigrate.name;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Parse Animal: %@",animalName);
    }
    
    Animal *animalToSave = [self retrieveCoreDataObjectWithEntityName:@"Animal"
                                                            andObjectId:animalToMigrate.objectId];
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting sync animal: %@", __PRETTY_FUNCTION__, animalName);
    }
    
    if (animalToMigrate.birthday) {
        animalToSave.cDataNascimento = animalToMigrate.birthday;
    }
    if (animalToMigrate.specie) {
        animalToSave.cEspecie = animalToMigrate.specie;
    }
    if (animalToMigrate.animalId) {
        animalToSave.cID = animalToMigrate.animalId;
    }
    if (animalToMigrate.name) {
        animalToSave.cNome = animalToMigrate.name;
    }
    if (animalToMigrate.notes) {
        animalToSave.cObs = animalToMigrate.notes;
    }
    if (animalToMigrate.breed) {
        animalToSave.cRaca = animalToMigrate.breed;
    }
    if (animalToMigrate.sex) {
        animalToSave.cSexo = animalToMigrate.sex;
    }
    if (animalToMigrate.photo) {
        if (animalToMigrate.photo.isDataAvailable) {
            if (MX_DESENV_MODE) {
                NSLog(@"%s downloading photo", __PRETTY_FUNCTION__);
            }
            NSData *photoData = [animalToMigrate.photo getData:&error];
            if (error) {
                NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                return NO;
            }
            animalToSave.cFoto = photoData;
            if (MX_DESENV_MODE) {
                NSLog(@"%s photo downloaded", __PRETTY_FUNCTION__);
            }
        }
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    animalToSave.cIdentifier = animalToMigrate.objectId;
    animalToSave.updatedAt = animalToMigrate.updatedAt;
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        [self.context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish sync animal: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return YES;
}
//- (BOOL)_syncCoreDataGenericObject:(NSManagedObject *)objectToMigrate andParseClass:(Class <PFSubclassing>)class andLogName:(NSString *)logName andRelationName:(NSString *)relationName andObjectName:(NSString *)objectName andPhotoField:(NSString *)fieldPhoto andBlock:(void (^)(PFObject **objectToSave, NSManagedObject **objectToMigrate, PFAnimal *animalRelated))blockAttributes
- (BOOL)_syncParseGenericObject:(PFObject *)objectToMigrate andCoreDataEntityName:(NSString *)entityName andObjectName:(NSString *)objectName andLogName:(NSString *)logName andPhotoField:(NSString *)fieldPhoto andBlock:(void (^)(NSManagedObject **objectToSave, PFObject **objectToMigrate, Animal *animalRelated))blockAttributes
{
    __block NSError *error = nil;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Parse %@: %@", logName, objectName);
    }
    
    NSManagedObject *objectToSave = [self retrieveCoreDataObjectWithEntityName:entityName
                                                                   andObjectId:objectToMigrate.objectId];
    Animal *animalRelated = [self retrieveCoreDataObjectWithEntityName:@"Animal"
                                                           andObjectId:[[objectToMigrate valueForKey:@"animal"] objectId]];
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting sync %@: %@", __PRETTY_FUNCTION__, logName, objectName);
    }
    
    blockAttributes(&objectToSave, &objectToMigrate, animalRelated);
    
    if (fieldPhoto) {
        if ([objectToMigrate valueForKey:@"photo"]) {
            PFFile *filePhoto = [objectToMigrate valueForKey:@"photo"];
            if (filePhoto.isDataAvailable) {
                if (MX_DESENV_MODE) {
                    NSLog(@"%s downloading photo", __PRETTY_FUNCTION__);
                }
                NSData *photoData = [filePhoto getData:&error];
                if (error) {
                    NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                    return NO;
                }
                [objectToSave setValue:photoData forKey:fieldPhoto];
                if (MX_DESENV_MODE) {
                    NSLog(@"%s photo downloaded", __PRETTY_FUNCTION__);
                }
            }
        }
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    [objectToSave setValue:objectToMigrate.objectId forKey:@"cIdentifier"];
    [objectToSave setValue:objectToMigrate.updatedAt forKey:@"updatedAt"];
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        [self.context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish sync %@: %@", __PRETTY_FUNCTION__, logName, objectName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return YES;
}

#pragma mark - Core Data Utils
- (Sync *)getSyncDates
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync"];
    
    NSError *error;
    
    NSArray *arrayResult = [self.context executeFetchRequest:request
                                                  error:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (arrayResult.count > 0) {
        return [arrayResult firstObject];
    }else{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sync" inManagedObjectContext:self.context];
                                       
        Sync *sync = [[Sync alloc] initWithEntity:entity
                   insertIntoManagedObjectContext:self.context];
        [sync initEmptyDates];
        [self.context save:nil];
        return sync;
    }
    
}

- (NSArray *)getAllObjectsWithEntityName:(NSString *)entityName andLastUpdateNilOfGreaterThan:(NSDate *)lastUpdateRef
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((updatedAt == nil) || (updatedAt > %@))", lastUpdateRef];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    
    [request setPredicate:predicate];
    
    NSError *error;
    
    NSArray *arrayResult = [self.context executeFetchRequest:request
                                                       error:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    return arrayResult;
    
}

- (id)retrieveCoreDataObjectWithEntityName:(NSString *)entityName andObjectId:(NSString *)objectId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(cIdentifier == %@)", objectId];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSError *error;
    
    NSArray *arrayResult = [self.context executeFetchRequest:request
                                                       error:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (arrayResult.count > 0) {
        return [arrayResult lastObject];
    }else{
        return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
    }
    
    return arrayResult;
}
//- (NSArray *)getAllPets
//{
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Animal"];
//    
//    NSError *error;
//    
//    NSArray *arrayResult = [self.context executeFetchRequest:request
//                                                  error:&error];
//    
//    if (error) {
//        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
//        return nil;
//    }
//    
//    if (MX_DESENV_MODE) {
//        NSLog(@"%s pet count: %d", __PRETTY_FUNCTION__, (int)arrayResult.count);
//    }
//    
//    return arrayResult;
//}

//- (NSDate *)mostRecentUpdatedAtDateForEntityWithName:(NSString *)entityName
//{
//    __block NSDate *date = nil;
//    __block NSError *error = nil;
//    //
//    // Create a new fetch request for the specified entity
//    //
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
//    //
//    // Set the sort descriptors on the request to sort by updatedAt in descending order
//    //
//    [request setSortDescriptors:[NSArray arrayWithObject:
//                                 [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
//    //
//    // You are only interested in 1 result so limit the request to 1
//    //
//    [request setFetchLimit:1];
//    dispatch_sync(dispatch_get_main_queue(), ^(void) {
//        NSArray *results = [self.context executeFetchRequest:request error:&error];
//        if ([results lastObject])   {
//            //
//            // Set date to the fetched result
//            //
//            date = [[results lastObject] valueForKey:@"updatedAt"];
//        }else{
//            date = [NSDate dateWithTimeIntervalSince1970:0];
//        }
//    });
//    if (error) {
//        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
//        return nil;
//    }
//    
//    return date;
//}

#pragma mark - Parse Utils
- (NSArray *)getAllObjectsWithClass:(Class<PFSubclassing>)class andLastUpdateNilOfGreaterThan:(NSDate *)lastUpdateRef
{
    PFQuery *query = [class query];
    
    [query whereKey:@"updatedAt" greaterThan:lastUpdateRef];
    
    NSError *error = nil;

    NSArray *arrayResults = [query findObjects:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    return arrayResults;
}

//- (void)retrieveOrCreateObjectWithClass:(Class<PFSubclassing>)class andIdentifier:(NSString *)identifier andPutInPFObject:(PFObject **)parseObject andToken:(NSString **)token
//{
//    if (identifier && ![identifier isEqualToString:@""]) {
//        if (MX_DESENV_MODE) {
//            NSLog(@"%s object has already migrated (token: %@)", __PRETTY_FUNCTION__, identifier);
//        }
//
//        *parseObject = [self retrieveObjectWithClass:class andToken:identifier];
//
//        *token = identifier;
//    }else{
//        *parseObject = [class object];
//
//        *token = [self randomStringToken];
//    }
//}
//
//- (id)retrieveObjectWithClass:(Class<PFSubclassing>)class andToken:(NSString *)token
//{
//    PFObject *object = nil;
//
//
//    PFQuery *queryLocally = [class query];
//    [queryLocally fromLocalDatastore];
//    [queryLocally whereKey:@"identifier" equalTo:token];
//    object = [queryLocally getFirstObject];
//
//    if (object) {
//        if (MX_DESENV_MODE) {
//            NSLog(@"%s object: %@ retrieved from local datastore", __PRETTY_FUNCTION__, object.objectId);
//        }
//        return object;
//    }
//
//    PFQuery *queryRemotely = [class query];
//    [queryRemotely whereKey:@"identifier" equalTo:token];
//    object = [queryRemotely getFirstObject];
//
//    if (object) {
//        if (MX_DESENV_MODE) {
//            NSLog(@"%s object: %@ retrieved from server", __PRETTY_FUNCTION__, object.objectId);
//        }
//        return object;
//    }
//
//    return [class object];
//}

//- (NSDate *)mostRecentUpdatedAtDateForClass:(Class <PFSubclassing>)class
//{
//    NSError *error;
//
//    NSDate *dateLastUpdated = nil;
//
//    PFQuery *query = [class query];
//
//    [query setLimit:1];
//    [query orderByDescending:@"updatedAt"];
//    NSArray *arrayObjects = [query findObjects:&error];
//    if (!error) {
//        if (arrayObjects && (arrayObjects.count > 0)) {
//            PFObject *object = [arrayObjects lastObject];
//            dateLastUpdated = [object updatedAt];
//        }else{
//            dateLastUpdated = [NSDate dateWithTimeIntervalSince1970:0];
//        }
//    }else{
//        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
//        return nil;
//    }
//
//    return dateLastUpdated;
//}


#pragma mark - General Utils
//- (NSString *)randomStringToken
//{
//    return [self randomStringWithLength:20];
//}
//
//- (NSString *)randomStringWithLength:(int)len
//{
//    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
//    
//    NSMutableString *s = [NSMutableString stringWithCapacity:len];
//    for (NSUInteger i = 0U; i < len; i++)
//    {
//        u_int32_t r = arc4random() % [alphabet length];
//        unichar   c = [alphabet characterAtIndex:r];
//        [s appendFormat:@"%C", c];
//    }
//    return [[NSString alloc] initWithString:s];
//}

//- (void)savePhoto:(NSData *)photo withToken:(NSString *)token  error:(NSError **)error
//{
//    NSString *filePath = [NSString stringWithFormat:@"photos/%@.png", token];
//    
//    if ([FCFileManager existsItemAtPath:filePath]) {
//        [FCFileManager removeItemAtPath:filePath
//                                  error:&*error];
//        
//        if (*error) {
//            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, [*error localizedDescription]);
//            return;
//        }
//    }
//    
//    [FCFileManager writeFileAtPath:filePath
//                           content:photo
//                             error:&*error];
//    
//    if (*error) {
//        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, [*error localizedDescription]);
//        return;
//    }
//}

- (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlagsDate = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlagsDate fromDate:date];
    unsigned unitFlagsTime = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
    NSDateComponents *timeComponents = [calendar components:unitFlagsTime fromDate:time];
    
    [dateComponents setSecond:[timeComponents second]];
    [dateComponents setHour:[timeComponents hour]];
    [dateComponents setMinute:[timeComponents minute]];
    
    NSDate *combDate = [calendar dateFromComponents:dateComponents];
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n%@\n%@\n%@", date, time, combDate);
    }
    
    return combDate;
}
@end
