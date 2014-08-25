//
//  MPPetEditViewController.m
//  MyPets
//
//  Created by HP Developer on 13/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPPetEditViewController.h"
#import "MPCoreDataService.h"
#import "Animal.h"
#import "MPLibrary.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "MPAds.h"
#import <iAd/iAd.h>

#define kMAX_PHOTO_SIZE 640

@interface MPPetEditViewController ()  <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    MPAds *ads;
}


@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@property (weak, nonatomic) IBOutlet UIButton *btnFoto;
@property (weak, nonatomic) IBOutlet UITextField *editNome;
@property (weak, nonatomic) IBOutlet UITextField *editNascimento;
@property (weak, nonatomic) IBOutlet UITextField *editSexo;
@property (weak, nonatomic) IBOutlet UITextField *editEspecie;
@property (weak, nonatomic) IBOutlet UITextField *editRaca;

@end

@implementation MPPetEditViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLS(@"Editar");
    self.navigationItem.title = self.title;
    
    self.editNome.placeholder       = NSLS(@"placeholderPetNome");
    self.editNascimento.placeholder = NSLS(@"placeholderPetNascimento");
    self.editSexo.placeholder       = NSLS(@"placeholderPetSexo");
    self.editEspecie.placeholder    = NSLS(@"placeholderPetEspécie");
    self.editRaca.placeholder       = NSLS(@"placeholderPetRaça");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self carregarTeclados];
    
    if ([MPTargets targetAds]) {
        //self.canDisplayBannerAds = YES;
        ads = [[MPAds alloc] initWithScrollView:self.tableView viewController:self admobID:@"ca-app-pub-8687233994493144/1661841561"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Pet Edit Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self atualizarPagina];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Métodos
- (void)atualizarPagina
{
    if ([[MPCoreDataService shared] animalSelected]) {
        Animal *animal = [[MPCoreDataService shared] animalSelected];
        
        self.editNome.text       = animal.cNome;
        self.editNascimento.text = [MPLibrary date:animal.cDataNascimento
                                          toFormat:NSLS(@"dd.MM.yyyy")];
        self.editSexo.text    = animal.cSexo;
        self.editEspecie.text = animal.cEspecie;
        self.editRaca.text    = animal.cRaca;
        [self.btnFoto setImage:[animal getFoto] forState:UIControlStateNormal];
    }
}

- (void)carregarTeclados
{
    UITextField *__editNome = self.editNome;
    [self.editNome setInputAccessoryView:[self returnToolBarToDismiss:&__editNome]];
    UITextField *__editRaca = self.editRaca;
    [self.editRaca setInputAccessoryView:[self returnToolBarToDismiss:&__editRaca]];
    
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker setTimeZone:[NSTimeZone defaultTimeZone]];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker addTarget:self
                   action:@selector(datePickerValueChanged:)
         forControlEvents:UIControlEventValueChanged];
    if ([[MPCoreDataService shared] animalSelected]) {
        Animal *animal = [[MPCoreDataService shared] animalSelected];
        [datePicker setDate:animal.cDataNascimento ? animal.cDataNascimento : [NSDate date]];
    }else{
        [datePicker setDate:[NSDate date]];
    }
    UITextField *__editNascimento = self.editNascimento;
    [self.editNascimento setInputView:datePicker];
    [self.editNascimento setInputAccessoryView:[self returnToolBarToDismiss:&__editNascimento]];
    
    
    UIPickerView *pickerViewSexo = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [pickerViewSexo setDelegate:self];
    [pickerViewSexo setDataSource:self];
    [pickerViewSexo setTag:1];
    UITextField *__editSexo = self.editSexo;
    [self.editSexo setInputView:pickerViewSexo];
    [self.editSexo setInputAccessoryView:[self returnToolBarToDismiss:&__editSexo]];
    
    UIPickerView *pickerViewEspecie = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [pickerViewEspecie setDelegate:self];
    [pickerViewEspecie setDataSource:self];
    [pickerViewEspecie setTag:2];
    UITextField *__editEspecie = self.editEspecie;
    [self.editEspecie setInputView:pickerViewEspecie];
    [self.editEspecie setInputAccessoryView:[self returnToolBarToDismiss:&__editEspecie]];
}

- (UIToolbar *)returnToolBarToDismiss:(UITextField **)textField
{
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:*textField action:@selector(resignFirstResponder)];
    [barButton setStyle:UIBarButtonItemStyleDone];
    [barButton setTitle:@"Ok"];
    
    UIBarButtonItem *barSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar setItems:[NSArray arrayWithObjects:barSpace,barButton, nil]];
    
    return toolbar;
}

#pragma mark - UIKeyboardNotification
- (void)keyboardWillShow:(NSNotification *)notification
{
    UIEdgeInsets edge =  UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, 264, self.tableView.scrollIndicatorInsets.right);
    [self.tableView setScrollIndicatorInsets:edge];
    [self.tableView setContentInset:edge];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets edge =  UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, 0, self.tableView.scrollIndicatorInsets.right);
    [self.tableView setScrollIndicatorInsets:edge];
    [self.tableView setContentInset:edge];
}

#pragma mark - IBActions
- (IBAction)btnButtonRightTouched:(id)sender
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    NSString *title = [NSString stringWithFormat:@"%@ %@?",NSLS(@"Deseja apagar"),[animal cNome]];
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:title
                                                        delegate:self
                                               cancelButtonTitle:NSLS(@"Cancelar")
                                          destructiveButtonTitle:NSLS(@"Apagar")
                                               otherButtonTitles:nil];
    
    [sheet setTag:1];
    [sheet showFromBarButtonItem:self.barButtonRight animated:YES];
}

- (IBAction)datePickerValueChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.editNascimento.text = [MPLibrary date:datePicker.date
                                      toFormat:NSLS(@"dd.MM.yyyy")];
}

- (IBAction)btnFotoTouched:(id)sender
{
    NSString *title = NSLS(@"Trocando a foto");
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:title
                                                        delegate:self
                                               cancelButtonTitle:NSLS(@"Cancelar")
                                          destructiveButtonTitle:NSLS(@"Tirar uma foto")
                                               otherButtonTitles:NSLS(@"Pegar do álbum"), nil];
    
    [sheet setTag:2];
    [sheet showFromBarButtonItem:self.barButtonRight animated:YES];
}


#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self keyboardWillShow:nil];
    UIView *view = [[[textField superview] superview] superview];
    if ([view isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)view;
        [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    BOOL loadAll = FALSE;
    
    if (textField == self.editNome) {
        loadAll = TRUE;
        [animal setCNome:self.editNome.text];
    }else if (textField == self.editNascimento){
        [animal setCDataNascimento:[(UIDatePicker *)self.editNascimento.inputView date]];
    }else if (textField == self.editSexo){
        [animal setCSexo:self.editSexo.text];
    }else if (textField == self.editEspecie){
        [animal setCEspecie:self.editEspecie.text];
    }else if (textField == self.editRaca){
        [animal setCRaca:self.editRaca.text];
    }
    
    [MPCoreDataService saveContext];
    if (loadAll) {
        [[MPCoreDataService shared] loadAllPets];
    }
    
}


#pragma mark - UITableViewDelegate and UITableViewDataSource
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: { return NSLS(@"Foto"); }
            break;
        case 1: { return NSLS(@"Nome"); }
            break;
        case 2: { return NSLS(@"Nascimento e Sexo"); }
            break;
        case 3: { return NSLS(@"Espécie e Raça"); }
            break;
    }
    
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0: { return NSLS(@"Toque na foto para editar"); }
            break;
    }
    
    return @"";
}

#pragma mark - UIPickerViewDelegate and UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        return 2;
    }else if (pickerView.tag == 2){
        return 3;
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        return [@[NSLS(@"Macho"), NSLS(@"Fêmea")] objectAtIndex:row];
    }else if (pickerView.tag == 2){
        return [@[NSLS(@"Canino"), NSLS(@"Felino"), NSLS(@"Outro")] objectAtIndex:row];;
    }
    
    return @"";
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        self.editSexo.text = [@[NSLS(@"Macho"), NSLS(@"Fêmea")] objectAtIndex:row];
    }else if (pickerView.tag == 2){
        self.editEspecie.text = [@[NSLS(@"Canino"), NSLS(@"Felino"), NSLS(@"Outro")] objectAtIndex:row];;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Deletar"     // Event category (required)
                                                                  action:@"Deletar Pet"  // Event action (required)
                                                                   label:@"Deletar Pet"          // Event label
                                                                   value:nil] build]];
            
            [[MPCoreDataService shared] deleteAnimalSelected];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }else if (actionSheet.tag == 2){
        if (buttonIndex == 0) {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            [picker setDelegate:self];
            [picker setAllowsEditing:YES];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [picker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
            [picker setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]];
            
            [self presentViewController:picker animated:YES completion:^{}];
        
        }else if(buttonIndex == 1){
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            [picker setDelegate:self];
            [picker setAllowsEditing:YES];
            
            [self presentViewController:picker animated:YES completion:^{}];
        }
    }
}

#pragma mark UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *pickedPhoto = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *resizedPhoto = [MPLibrary imageWithoutCutsWithImage:pickedPhoto widthBased:kMAX_PHOTO_SIZE];
	
    Animal *animal = [[MPCoreDataService shared] animalSelected];
    [animal setCFoto:UIImageJPEGRepresentation(resizedPhoto, 1.0)];
    
    [self.btnFoto setImage:[animal getFoto] forState:UIControlStateNormal];
    
    [MPCoreDataService saveContext];
    [[MPCoreDataService shared] loadAllPets];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Fotos"     // Event category (required)
                                                          action:@"Foto Pet"  // Event action (required)
                                                           label:@"Foto Pet"          // Event label
                                                           value:nil] build]];

    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
