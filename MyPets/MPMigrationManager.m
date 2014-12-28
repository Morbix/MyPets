//
//  MPMigrationManager.m
//  MyPets
//
//  Created by Henrique Morbin on 24/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPMigrationManager.h"
#import "MPInternetManager.h"
#import "MPAppDelegate.h"
#import "FCFileManager.h"
#import "MPReminderManager.h"

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

@interface MPMigrationManager ()
{
    NSManagedObjectContext *context;
    NSError *errorBlocks;
}
@end

@implementation MPMigrationManager

- (void)startMigration
{
    errorBlocks = nil;
    
    context = [(MPAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    if ([[MPInternetManager shared] hasInternetConnectionViaWifi]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self startMigrationThreadSafe];
        });
    }
}

- (void)startMigrationThreadSafe
{
    NSArray *arrayPets = [self getAllPets];
    
    if (arrayPets.count > 0) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s Starting Migration...", __PRETTY_FUNCTION__);
        }
        
        //[[context persistentStoreCoordinator] lock];
        
        BOOL completed = YES;
        
        for (Animal *animal in arrayPets) {
            completed = [[MPInternetManager shared] hasInternetConnectionViaWifi];
            if (!completed) { break; }
            
            PFAnimal *animalMigrated = [self migrateAnimal:animal];
            completed =  animalMigrated ? YES : NO;
            if (!completed) { break; }
            
            if (animal.cArrayBanhos.count > 0) {
                for (Banho *banho in animal.cArrayBanhos.allObjects) {
                    PFBath *bathMigrated = [self migrateBath:banho toAnimal:animalMigrated];
                    completed = bathMigrated ? YES : NO;
                    if (!completed) { break; }
                }
            }
            if (!completed) { break; }
            
            if (animal.cArrayConsultas.count > 0) {
                for (Consulta *consulta in animal.cArrayConsultas.allObjects) {
                    PFAppointment *appointmentMigrated = [self migrateAppointment:consulta toAnimal:animalMigrated];
                    completed = appointmentMigrated ? YES : NO;
                    if (!completed) { break; }
                }
            }
            if (!completed) { break; }
            
            if (animal.cArrayMedicamentos.count > 0) {
                for (Medicamento *medicamento in animal.cArrayMedicamentos.allObjects) {
                    PFMedice *medicineMigrated = [self migrateMedicine:medicamento toAnimal:animalMigrated];
                    completed = medicineMigrated ? YES : NO;
                    if (!completed) { break; }
                }
            }
            if (!completed) { break; }
            
            if (animal.cArrayPesos.count > 0) {
                for (Peso *peso in animal.cArrayPesos.allObjects) {
                    PFWeight *weightMigrated = [self migrateWeight:peso toAnimal:animalMigrated];
                    completed = weightMigrated ? YES : NO;
                    if (!completed) { break; }
                }
            }
            if (!completed) { break; }
            
            if (animal.cArrayVacinas.count > 0) {
                for (Vacina *vacina in animal.cArrayVacinas.allObjects) {
                    PFVaccine *vaccineMigrated = [self migrateVaccine:vacina toAnimal:animalMigrated];
                    completed = vaccineMigrated ? YES : NO;
                    if (!completed) { break; }
                }
            }
            if (!completed) { break; }
            
            if (animal.cArrayVermifugos.count > 0) {
                for (Vermifugo *vermifugo in animal.cArrayVermifugos.allObjects) {
                    PFVermifuge *vermifugeMigrated = [self migrateVermifuge:vermifugo toAnimal:animalMigrated];
                    completed = vermifugeMigrated ? YES : NO;
                    if (!completed) { break; }
                }
            }
            if (!completed) { break; }
        }
        
        
        //[[context persistentStoreCoordinator] unlock];
        
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
    }
}

- (PFAnimal *)migrateAnimal:(Animal *)animalToMigrate
{
    __block NSError *error = nil;
    
    PFAnimal *animalToSave = nil;
    
    NSString *animalName = animalToMigrate.cNome;
    
    NSString *token = nil;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Animal: %@",animalName);
    }
    
    if (animalToMigrate.cIdentifier && ![animalToMigrate.cIdentifier isEqualToString:@""]) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s animal: %@ has already migrated (token: %@)", __PRETTY_FUNCTION__ ,animalName, animalToMigrate.cIdentifier);
        }
        
        animalToSave = [self retrieveObjectWithClass:[PFAnimal class] andToken:animalToMigrate.cIdentifier];
        
        token = animalToMigrate.cIdentifier;
    }else{
        animalToSave = [PFAnimal object];

        token = [self randomStringToken];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting migrate animal: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    
    [animalToSave setIdentifier:token];
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
            NSLog(@"%s saving photo locally: %@", __PRETTY_FUNCTION__ ,token);
        }
        [self savePhoto:animalToMigrate.cFoto withToken:token error:&error];
        if (error) {
            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
            return nil;
        }
        
        
        PFFile *filePhoto = animalToSave.photo;
        if (!filePhoto) {
            if (MX_DESENV_MODE) {
                NSLog(@"%s sending photo: %@", __PRETTY_FUNCTION__ ,token);
            }
            filePhoto = [PFFile fileWithName:token
                                        data:animalToMigrate.cFoto
                                 contentType:@"image/png"];
            [filePhoto save:&error];
            if (error) {
                NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                return nil;
            }
            
            if (MX_DESENV_MODE) {
                NSLog(@"%s photo sent: %@", __PRETTY_FUNCTION__ ,token);
            }
            
            [animalToSave setPhoto:filePhoto];
        }
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s pinning animal: %@", __PRETTY_FUNCTION__ , animalName);
    }
    [animalToSave pin:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    animalToMigrate.cIdentifier = token;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving animal: %@", __PRETTY_FUNCTION__ , animalName);
    }
    [animalToSave save:&error];
    if (error) {
        [animalToSave unpin];
        
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving relation between user and animal: %@", __PRETTY_FUNCTION__ , animalName);
    }
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"relationOfAnimal"];
    [relation addObject:animalToSave];
    [[PFUser currentUser] save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish migrate animal: %@", __PRETTY_FUNCTION__ ,animalName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return animalToSave;
}

- (PFBath *)migrateBath:(Banho *)bathToMigrate toAnimal:(PFAnimal *)animalMigrated
{
    __block NSError *error = nil;
    
    PFBath *bathToSave = nil;
    
    NSString * animalName = bathToMigrate.cAnimal.cNome;
    NSString * bathName = bathToMigrate.cData.description;
    
    NSString *token = nil;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Animal: %@ ===> Bath: %@", animalName, bathName);
    }
    
    if (bathToMigrate.cIdentifier && ![bathToMigrate.cIdentifier isEqualToString:@""]) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s bath: %@ has already migrated (token: %@)", __PRETTY_FUNCTION__ ,bathName, bathToMigrate.cIdentifier);
        }
        
        bathToSave = [self retrieveObjectWithClass:[PFBath class] andToken:bathToMigrate.cIdentifier];
        
        token = bathToMigrate.cIdentifier;
    }else{
        bathToSave = [PFBath object];
        
        token = [self randomStringToken];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting migrate bath: %@", __PRETTY_FUNCTION__ ,bathName);
    }
    
    [bathToSave setIdentifier:token];
    [bathToSave setAnimal:animalMigrated];
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
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s pinning bath: %@", __PRETTY_FUNCTION__ , bathName);
    }
    [bathToSave pin:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    bathToMigrate.cIdentifier = token;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving bath: %@", __PRETTY_FUNCTION__ , bathName);
    }
    [bathToSave save:&error];
    if (error) {
        [bathToSave unpin];
        
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving relation between animal: %@ and bath: %@", __PRETTY_FUNCTION__ , animalName, bathName);
    }
    PFRelation *relation = [animalMigrated relationForKey:@"relationOfBath"];
    [relation addObject:bathToSave];
    [animalMigrated save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish migrate bath: %@", __PRETTY_FUNCTION__ ,bathName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return bathToSave;
}

- (PFAppointment *)migrateAppointment:(Consulta *)appointmentToMigrate toAnimal:(PFAnimal *)animalMigrated
{
    __block NSError *error = nil;
    
    PFAppointment *appointmentToSave = nil;
    
    NSString * animalName = appointmentToMigrate.cAnimal.cNome;
    NSString * appointmentName = appointmentToMigrate.cData.description;
    
    NSString *token = nil;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Animal: %@ ===> Appointment: %@", animalName, appointmentName);
    }
    
    if (appointmentToMigrate.cIdentifier && ![appointmentToMigrate.cIdentifier isEqualToString:@""]) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s appointment: %@ has already migrated (token: %@)", __PRETTY_FUNCTION__ , appointmentName, appointmentToMigrate.cIdentifier);
        }
        
        appointmentToSave = [self retrieveObjectWithClass:[PFAppointment class] andToken:appointmentToMigrate.cIdentifier];
        
        token = appointmentToMigrate.cIdentifier;
    }else{
        appointmentToSave = [PFAppointment object];
        
        token = [self randomStringToken];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting migrate appointment: %@", __PRETTY_FUNCTION__, appointmentName);
    }
    
    [appointmentToSave setIdentifier:token];
    [appointmentToSave setAnimal:animalMigrated];
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
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s pinning appointment: %@", __PRETTY_FUNCTION__ , appointmentName);
    }
    [appointmentToSave pin:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    appointmentToMigrate.cIdentifier = token;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving appointment: %@", __PRETTY_FUNCTION__ , appointmentName);
    }
    [appointmentToSave save:&error];
    if (error) {
        [appointmentToSave unpin];
        
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving relation between animal: %@ and appointment: %@", __PRETTY_FUNCTION__ , animalName, appointmentName);
    }
    PFRelation *relation = [animalMigrated relationForKey:@"relationOfAppointment"];
    [relation addObject:appointmentToSave];
    [animalMigrated save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish migrate appointment: %@", __PRETTY_FUNCTION__ ,appointmentName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return appointmentToSave;
}

- (PFMedice *)migrateMedicine:(Medicamento *)medicineToMigrate toAnimal:(PFAnimal *)animalMigrated
{
    __block NSError *error = nil;
    
    PFMedice *medicineToSave = nil;
    
    NSString * animalName = medicineToMigrate.cAnimal.cNome;
    NSString * medicineName = medicineToMigrate.cData.description;
    
    NSString *token = nil;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Animal: %@ ===> Medicine: %@", animalName, medicineName);
    }
    
    if (medicineToMigrate.cIdentifier && ![medicineToMigrate.cIdentifier isEqualToString:@""]) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s medicine: %@ has already migrated (token: %@)", __PRETTY_FUNCTION__, medicineName, medicineToMigrate.cIdentifier);
        }
        
        medicineToSave = [self retrieveObjectWithClass:[PFMedice class] andToken:medicineToMigrate.cIdentifier];
        
        token = medicineToMigrate.cIdentifier;
    }else{
        medicineToSave = [PFMedice object];
        
        token = [self randomStringToken];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting migrate medicine: %@", __PRETTY_FUNCTION__, medicineName);
    }
    
    [medicineToSave setIdentifier:token];
    [medicineToSave setAnimal:animalMigrated];
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
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s pinning medicine: %@", __PRETTY_FUNCTION__ , medicineName);
    }
    [medicineToSave pin:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    medicineToMigrate.cIdentifier = token;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving medicine: %@", __PRETTY_FUNCTION__ ,medicineName);
    }
    [medicineToSave save:&error];
    if (error) {
        [medicineToSave unpin];
        
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving relation between animal: %@ and medicine: %@", __PRETTY_FUNCTION__ , animalName, medicineName);
    }
    PFRelation *relation = [animalMigrated relationForKey:@"relationOfMedicine"];
    [relation addObject:medicineToSave];
    [animalMigrated save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish migrate medicine: %@", __PRETTY_FUNCTION__, medicineName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return medicineToSave;
}

- (PFWeight *)migrateWeight:(Peso *)weightToMigrate toAnimal:(PFAnimal *)animalMigrated
{
    __block NSError *error = nil;
    
    PFWeight *weightToSave = nil;
    
    NSString * animalName = weightToMigrate.cAnimal.cNome;
    NSString * weightName = weightToMigrate.cData.description;
    
    NSString *token = nil;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Animal: %@ ===> Weight: %@", animalName, weightName);
    }
    
    if (weightToMigrate.cIdentifier && ![weightToMigrate.cIdentifier isEqualToString:@""]) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s weight: %@ has already migrated (token: %@)", __PRETTY_FUNCTION__, weightName, weightToMigrate.cIdentifier);
        }
        
        weightToSave = [self retrieveObjectWithClass:[PFWeight class] andToken:weightToMigrate.cIdentifier];
        
        token = weightToMigrate.cIdentifier;
    }else{
        weightToSave = [PFWeight object];
        
        token = [self randomStringToken];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting migrate weight: %@", __PRETTY_FUNCTION__, weightName);
    }
    
    [weightToSave setIdentifier:token];
    [weightToSave setAnimal:animalMigrated];
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
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s pinning weight: %@", __PRETTY_FUNCTION__ , weightName);
    }
    [weightToSave pin:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    weightToMigrate.cIdentifier = token;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving bath: %@", __PRETTY_FUNCTION__ , weightName);
    }
    [weightToSave save:&error];
    if (error) {
        [weightToSave unpin];
        
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving relation between animal: %@ and weight: %@", __PRETTY_FUNCTION__ , animalName, weightName);
    }
    PFRelation *relation = [animalMigrated relationForKey:@"relationOfWeight"];
    [relation addObject:weightToSave];
    [animalMigrated save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish migrate weight: %@", __PRETTY_FUNCTION__, weightName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return weightToSave;
}

- (PFVaccine *)migrateVaccine:(Vacina *)vaccineToMigrate toAnimal:(PFAnimal *)animalMigrated
{
    __block NSError *error = nil;
    
    PFVaccine *vaccineToSave = nil;
    
    NSString * animalName = vaccineToMigrate.cAnimal.cNome;
    NSString * vaccineName = vaccineToMigrate.cData.description;
    
    NSString *token = nil;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Animal: %@ ===> Vaccine: %@", animalName, vaccineName);
    }
    
    if (vaccineToMigrate.cIdentifier && ![vaccineToMigrate.cIdentifier isEqualToString:@""]) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s vaccine: %@ has already migrated (token: %@)", __PRETTY_FUNCTION__, vaccineName, vaccineToMigrate.cIdentifier);
        }
        
        vaccineToSave = [self retrieveObjectWithClass:[PFVaccine class] andToken:vaccineToMigrate.cIdentifier];
        
        token = vaccineToMigrate.cIdentifier;
    }else{
        vaccineToSave = [PFVaccine object];
        
        token = [self randomStringToken];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting migrate vaccine: %@", __PRETTY_FUNCTION__, vaccineName);
    }
    
    [vaccineToSave setIdentifier:token];
    [vaccineToSave setAnimal:animalMigrated];
    [vaccineToSave setOwner:[PFUser currentUser]];
    
    if (vaccineToMigrate.cData) {
        [vaccineToSave setDateAndTime:vaccineToMigrate.cData];
    }
    if (vaccineToMigrate.cDataVacina) {
        [vaccineToSave setDateAndTimeVaccine:vaccineToMigrate.cDataVacina];
    }
    if (vaccineToMigrate.cID) {
        [vaccineToSave setVaccineId:vaccineToMigrate.cID];
    }
    if (vaccineToMigrate.cLembrete) {
        [vaccineToSave setReminder:[MPReminderManager translateReminderStringToInt:vaccineToMigrate.cLembrete]];
    }
    if (vaccineToMigrate.cObs) {
        [vaccineToSave setNotes:vaccineToMigrate.cObs];
    }
    if (vaccineToMigrate.cPeso) {
        [vaccineToSave setWeight:vaccineToMigrate.cPeso.floatValue];
    }
    if (vaccineToMigrate.cDose) {
        [vaccineToSave setDose:vaccineToMigrate.cDose];
    }
    if (vaccineToMigrate.cVeterinario) {
        [vaccineToSave setVeterinarian:vaccineToMigrate.cVeterinario];
    }
    
    if (vaccineToMigrate.cSelo) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s saving photo locally: %@", __PRETTY_FUNCTION__ ,token);
        }
        [self savePhoto:vaccineToMigrate.cSelo withToken:token error:&error];
        if (error) {
            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
            return nil;
        }
        
        
        PFFile *filePhoto = vaccineToSave.photo;
        if (!filePhoto) {
            if (MX_DESENV_MODE) {
                NSLog(@"%s sending photo: %@", __PRETTY_FUNCTION__ ,token);
            }
            filePhoto = [PFFile fileWithName:token
                                        data:vaccineToMigrate.cSelo
                                 contentType:@"image/png"];
            [filePhoto save:&error];
            if (error) {
                NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                return nil;
            }
            
            if (MX_DESENV_MODE) {
                NSLog(@"%s photo sent: %@", __PRETTY_FUNCTION__ ,token);
            }
            
            [vaccineToSave setPhoto:filePhoto];
        }
    }

    
    if (MX_DESENV_MODE) {
        NSLog(@"%s pinning vaccine: %@", __PRETTY_FUNCTION__ , vaccineName);
    }
    [vaccineToSave pin:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    vaccineToMigrate.cIdentifier = token;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving vaccine: %@", __PRETTY_FUNCTION__ , vaccineName);
    }
    [vaccineToSave save:&error];
    if (error) {
        [vaccineToSave unpin];
        
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving relation between animal: %@ and vaccine: %@", __PRETTY_FUNCTION__ , animalName, vaccineName);
    }
    PFRelation *relation = [animalMigrated relationForKey:@"relationOfVaccine"];
    [relation addObject:vaccineToSave];
    [animalMigrated save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish migrate vaccine: %@", __PRETTY_FUNCTION__, vaccineName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return vaccineToSave;
}

- (PFVermifuge *)migrateVermifuge:(Vermifugo *)vermifugeToMigrate toAnimal:(PFAnimal *)animalMigrated
{
    __block NSError *error = nil;
    
    PFVermifuge *vermifugeToSave = nil;
    
    NSString * animalName = vermifugeToMigrate.cAnimal.cNome;
    NSString * vermifugeName = vermifugeToMigrate.cData.description;
    
    NSString *token = nil;
    
    if (MX_DESENV_MODE) {
        NSLog(@"\n===> Animal: %@ ===> Vermifuge: %@", animalName, vermifugeName);
    }
    
    if (vermifugeToMigrate.cIdentifier && ![vermifugeToMigrate.cIdentifier isEqualToString:@""]) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s vermifuge: %@ has already migrated (token: %@)", __PRETTY_FUNCTION__, vermifugeName, vermifugeToMigrate.cIdentifier);
        }
        
        vermifugeToSave = [self retrieveObjectWithClass:[PFVermifuge class] andToken:vermifugeToMigrate.cIdentifier];
        
        token = vermifugeToMigrate.cIdentifier;
    }else{
        vermifugeToSave = [PFVermifuge object];
        
        token = [self randomStringToken];
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s starting migrate vermifuge: %@", __PRETTY_FUNCTION__, vermifugeName);
    }
    
    [vermifugeToSave setIdentifier:token];
    [vermifugeToSave setAnimal:animalMigrated];
    [vermifugeToSave setOwner:[PFUser currentUser]];
    
    if (vermifugeToMigrate.cData) {
        [vermifugeToSave setDateAndTime:vermifugeToMigrate.cData];
    }
    if (vermifugeToMigrate.cDataVacina) {
        [vermifugeToSave setDateAndTimeVaccine:vermifugeToMigrate.cDataVacina];
    }
    if (vermifugeToMigrate.cID) {
        [vermifugeToSave setVermifugeId:vermifugeToMigrate.cID];
    }
    if (vermifugeToMigrate.cLembrete) {
        [vermifugeToSave setReminder:[MPReminderManager translateReminderStringToInt:vermifugeToMigrate.cLembrete]];
    }
    if (vermifugeToMigrate.cObs) {
        [vermifugeToSave setNotes:vermifugeToMigrate.cObs];
    }
    if (vermifugeToMigrate.cPeso) {
        [vermifugeToSave setWeight:vermifugeToMigrate.cPeso.floatValue];
    }
    if (vermifugeToMigrate.cDose) {
        [vermifugeToSave setDose:vermifugeToMigrate.cDose];
    }
    
    if (vermifugeToMigrate.cSelo) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s saving photo locally: %@", __PRETTY_FUNCTION__ ,token);
        }
        [self savePhoto:vermifugeToMigrate.cSelo withToken:token error:&error];
        if (error) {
            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
            return nil;
        }
        
        
        PFFile *filePhoto = vermifugeToSave.photo;
        if (!filePhoto) {
            if (MX_DESENV_MODE) {
                NSLog(@"%s sending photo: %@", __PRETTY_FUNCTION__ ,token);
            }
            filePhoto = [PFFile fileWithName:token
                                        data:vermifugeToMigrate.cSelo
                                 contentType:@"image/png"];
            [filePhoto save:&error];
            if (error) {
                NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
                return nil;
            }
            
            if (MX_DESENV_MODE) {
                NSLog(@"%s photo sent: %@", __PRETTY_FUNCTION__ ,token);
            }
            
            [vermifugeToSave setPhoto:filePhoto];
        }
    }
    
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s pinning vermifuge: %@", __PRETTY_FUNCTION__, vermifugeName);
    }
    [vermifugeToSave pin:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving context", __PRETTY_FUNCTION__);
    }
    vermifugeToMigrate.cIdentifier = token;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [context save:&error];
    });
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving vermifuge: %@", __PRETTY_FUNCTION__ , vermifugeName);
    }
    [vermifugeToSave save:&error];
    if (error) {
        [vermifugeToSave unpin];
        
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s saving relation between animal: %@ and vermifuge: %@", __PRETTY_FUNCTION__ , animalName, vermifugeName);
    }
    PFRelation *relation = [animalMigrated relationForKey:@"relationOfVermifuge"];
    [relation addObject:vermifugeToSave];
    [animalMigrated save:&error];
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s finish migrate vermifuge: %@", __PRETTY_FUNCTION__, vermifugeName);
    }
    if (MX_DESENV_MODE) {
        NSLog(@"\n\n");
    }
    
    return vermifugeToSave;
}

#pragma mark - Core Data
- (NSArray *)getAllPets
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Animal"];
    
    NSError *error;
    
    NSArray *arrayResult = [context executeFetchRequest:request
                                                  error:&error];
    
    if (error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return nil;
    }
    
    if (MX_DESENV_MODE) {
        NSLog(@"%s pet count: %d", __PRETTY_FUNCTION__, (int)arrayResult.count);
    }
    
    return arrayResult;
}

#pragma mark - Utils
- (NSString *)randomStringToken
{
    return [self randomStringWithLength:20];
}

- (NSString *)randomStringWithLength:(int)len
{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *s = [NSMutableString stringWithCapacity:len];
    for (NSUInteger i = 0U; i < len; i++)
    {
        u_int32_t r = arc4random() % [alphabet length];
        unichar   c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return [[NSString alloc] initWithString:s];
}

- (void)savePhoto:(NSData *)photo withToken:(NSString *)token  error:(NSError **)error
{
    NSString *filePath = [NSString stringWithFormat:@"photos/%@.png", token];
    
    if ([FCFileManager existsItemAtPath:filePath]) {
        [FCFileManager removeItemAtPath:filePath
                                  error:&*error];
        
        if (*error) {
            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, [*error localizedDescription]);
            return;
        }
    }
    
    [FCFileManager writeFileAtPath:filePath
                           content:photo
                             error:&*error];
    
    if (*error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, [*error localizedDescription]);
        return;
    }
}

- (id)retrieveObjectWithClass:(Class<PFSubclassing>)class andToken:(NSString *)token
{
    PFObject *object = nil;
    
    
    PFQuery *queryLocally = [class query];
    [queryLocally fromLocalDatastore];
    [queryLocally whereKey:@"identifier" equalTo:token];
    object = [queryLocally getFirstObject];
    
    if (object) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s object: %@ retrieved from local datastore", __PRETTY_FUNCTION__, object.objectId);
        }
        return object;
    }
    
    PFQuery *queryRemotely = [class query];
    [queryRemotely whereKey:@"identifier" equalTo:token];
    object = [queryRemotely getFirstObject];
    
    if (object) {
        if (MX_DESENV_MODE) {
            NSLog(@"%s object: %@ retrieved from server", __PRETTY_FUNCTION__, object.objectId);
        }
        return object;
    }
    
    return [class object];
}

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
