//
//  MPVacinaEditViewController.m
//  MyPets
//
//  Created by HP Developer on 17/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPVacinaEditViewController.h"
#import "MPCoreDataService.h"
#import "MPLibrary.h"
#import "MPLembretes.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#define kMAX_PHOTO_SIZE 640

@interface MPVacinaEditViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@property (weak, nonatomic) IBOutlet UIButton *btnFoto;
@property (weak, nonatomic) IBOutlet UIImageView *imageFoto;
@property (weak, nonatomic) IBOutlet UITextField *editData;
@property (weak, nonatomic) IBOutlet UITextField *editHora;
@property (weak, nonatomic) IBOutlet UITextField *editLembreteTipo;
@property (weak, nonatomic) IBOutlet UITextField *editLembreteData;
@property (weak, nonatomic) IBOutlet UITextField *editLembreteHora;
@property (weak, nonatomic) IBOutlet UITextField *editVeterinario;
@property (weak, nonatomic) IBOutlet UITextField *editNotas;
@end

@implementation MPVacinaEditViewController

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
    
    self.editData.placeholder         = NSLS(@"placeholderPetData");
    self.editHora.placeholder         = NSLS(@"placeholderPetHora");
    self.editLembreteTipo.placeholder = NSLS(@"placeholderLembrete");
    self.editLembreteData.placeholder = NSLS(@"placeholderPetData");
    self.editLembreteHora.placeholder = NSLS(@"placeholderPetHora");
    self.editVeterinario.placeholder  = NSLS(@"placeholderVeterinario");
    self.editNotas.placeholder        = NSLS(@"placeholderNotas");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [self carregarTeclados];
    
    [self createBannerView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Vacina Edit Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self requestBanner:kBanner_Edits];
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
    if ([[MPCoreDataService shared] vacinaSelected]) {
        Vacina *vacina = [[MPCoreDataService shared] vacinaSelected];
        
        [self.imageFoto setImage:[vacina getFoto]];
        self.editData.text = [MPLibrary date:vacina.cDataVacina
                                          toFormat:NSLS(@"dd.MM.yyyy")];
        self.editHora.text = [MPLibrary date:vacina.cDataVacina
                                    toFormat:NSLS(@"hh:mm a")];
        
        if (vacina.cData) {
            self.editLembreteData.text = [MPLibrary date:vacina.cData
                                        toFormat:NSLS(@"dd.MM.yyyy")];
            self.editLembreteHora.text = [MPLibrary date:vacina.cData
                                        toFormat:NSLS(@"hh:mm a")];
        }
        
        self.editLembreteTipo.text = vacina.cLembrete;
        self.editVeterinario.text  = vacina.cVeterinario;
        self.editNotas.text        = vacina.cObs;
    }
}

- (void)carregarTeclados
{
    Vacina *vacina = nil;
    if ([[MPCoreDataService shared] vacinaSelected]) {
         vacina = [[MPCoreDataService shared] vacinaSelected];
    }
    
    UITextField *__editData = self.editData;
    [self.editData setInputAccessoryView:[self returnToolBarToDismiss:&__editData]];
    UITextField *__editHora = self.editHora;
    [self.editHora setInputAccessoryView:[self returnToolBarToDismiss:&__editHora]];
    UITextField *__editLembreteTipo = self.editLembreteTipo;
    [self.editLembreteTipo setInputAccessoryView:[self returnToolBarToDismiss:&__editLembreteTipo]];
    UITextField *__editLembreteData = self.editLembreteData;
    [self.editLembreteData setInputAccessoryView:[self returnToolBarToDismiss:&__editLembreteData]];
    UITextField *__editLembreteHora = self.editLembreteHora;
    [self.editLembreteHora setInputAccessoryView:[self returnToolBarToDismiss:&__editLembreteHora]];
    UITextField *__editVeterinario = self.editVeterinario;
    [self.editVeterinario setInputAccessoryView:[self returnToolBarToDismiss:&__editVeterinario]];
    UITextField *__editNotas = self.editNotas;
    [self.editNotas setInputAccessoryView:[self returnToolBarToDismiss:&__editNotas]];
    
    
    
    //Data
    UIDatePicker *datePicker1 = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker1 setTimeZone:[NSTimeZone defaultTimeZone]];
    [datePicker1 setDatePickerMode:UIDatePickerModeDate];
    [datePicker1 addTarget:self
                   action:@selector(datePickerValueChanged:)
         forControlEvents:UIControlEventValueChanged];
    [datePicker1 setTag:1];
    if (vacina) {
        [datePicker1 setDate:vacina.cDataVacina ? vacina.cDataVacina : [NSDate date]];
    }else{
        [datePicker1 setDate:[NSDate date]];
    }
    [self.editData setInputAccessoryView:[self returnToolBarToDismiss:&__editData]];
    [self.editData setInputView:datePicker1];
    
    //Hora
    UIDatePicker *datePicker2 = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker2 setTimeZone:[NSTimeZone defaultTimeZone]];
    [datePicker2 setDatePickerMode:UIDatePickerModeTime];
    [datePicker2 addTarget:self
                   action:@selector(datePickerValueChanged:)
         forControlEvents:UIControlEventValueChanged];
    [datePicker2 setTag:1];
    if (vacina) {
        [datePicker2 setDate:vacina.cDataVacina ? vacina.cDataVacina : [NSDate date]];
    }else{
        [datePicker2 setDate:[NSDate date]];
    }
    [self.editHora setInputAccessoryView:[self returnToolBarToDismiss:&__editHora]];
    [self.editHora setInputView:datePicker2];
    
    //Lembrete Data
    UIDatePicker *datePicker3 = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker3 setTimeZone:[NSTimeZone defaultTimeZone]];
    [datePicker3 setDatePickerMode:UIDatePickerModeDate];
    [datePicker3 addTarget:self
                    action:@selector(datePickerValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    [datePicker3 setTag:2];
    if (vacina) {
        [datePicker3 setDate:vacina.cData ? vacina.cData : [NSDate date]];
    }else{
        [datePicker3 setDate:[NSDate date]];
    }
    [self.editLembreteData setInputAccessoryView:[self returnToolBarToDismiss:&__editLembreteData]];
    [self.editLembreteData setInputView:datePicker3];
    
    //Lembrete Hora
    UIDatePicker *datePicker4 = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker4 setTimeZone:[NSTimeZone defaultTimeZone]];
    [datePicker4 setDatePickerMode:UIDatePickerModeTime];
    [datePicker4 addTarget:self
                    action:@selector(datePickerValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    [datePicker4 setTag:2];
    if (vacina) {
        [datePicker4 setDate:vacina.cData ? vacina.cData : [NSDate date]];
    }else{
        [datePicker4 setDate:[NSDate date]];
    }
    [self.editLembreteHora setInputAccessoryView:[self returnToolBarToDismiss:&__editLembreteHora]];
    [self.editLembreteHora setInputView:datePicker4];
    
    
    UIPickerView *pickerViewLembrete = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [pickerViewLembrete setDelegate:self];
    [pickerViewLembrete setDataSource:self];
    [pickerViewLembrete setTag:1];
    [self.editLembreteTipo setInputAccessoryView:[self returnToolBarToDismiss:&__editLembreteTipo]];
    [self.editLembreteTipo setInputView:pickerViewLembrete];
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
- (IBAction)barButtonRightTouched:(id)sender
{
    NSString *title = [NSString stringWithFormat:@"%@ %@?",NSLS(@"Deseja apagar"),NSLS(@"Vacina")];
    
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
    
    if (datePicker.tag == 1) {
        self.editData.text = [MPLibrary date:datePicker.date
                                    toFormat:NSLS(@"dd.MM.yyyy")];
        self.editHora.text = [MPLibrary date:datePicker.date
                                    toFormat:NSLS(@"hh:mm a")];
    }else{
        self.editLembreteData.text = [MPLibrary date:datePicker.date
                                            toFormat:NSLS(@"dd.MM.yyyy")];
        self.editLembreteHora.text = [MPLibrary date:datePicker.date
                                            toFormat:NSLS(@"hh:mm a")];
    }
}

- (IBAction)btnFotoTouched:(UIButton *)sender
{
    NSString *title = NSLS(@"Trocando a foto");
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:title
                                                        delegate:self
                                               cancelButtonTitle:NSLS(@"Cancelar")
                                          destructiveButtonTitle:NSLS(@"Tirar uma foto")
                                               otherButtonTitles:NSLS(@"Pegar do álbum"), NSLS(@"Mostrar foto em tela cheia"), nil];
    
    [sheet setTag:2];
    [sheet showFromRect:sender.frame inView:self.view animated:YES];
    //[sheet showFromBarButtonItem:self.barButtonRight animated:YES];
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
    Vacina *vacina = [[MPCoreDataService shared] vacinaSelected];
    BOOL loadAll = FALSE;
    BOOL loadNotify = FALSE;
    
    if (textField == self.editData) {
        [vacina setCDataVacina:[(UIDatePicker *)self.editData.inputView date]];
        [(UIDatePicker *)self.editHora.inputView setDate:vacina.cDataVacina];
    }else if (textField == self.editHora){
        [vacina setCDataVacina:[(UIDatePicker *)self.editHora.inputView date]];
        [(UIDatePicker *)self.editData.inputView setDate:vacina.cDataVacina];
    }else if (textField == self.editLembreteData) {
        [vacina setCData:[(UIDatePicker *)self.editLembreteData.inputView date]];
        [(UIDatePicker *)self.editLembreteHora.inputView setDate:vacina.cData];
        loadNotify = YES;
    }else if (textField == self.editLembreteHora){
        [vacina setCData:[(UIDatePicker *)self.editLembreteHora.inputView date]];
        [(UIDatePicker *)self.editLembreteData.inputView setDate:vacina.cData];
        loadNotify = YES;
    }else if (textField == self.editLembreteTipo){
        [vacina setCLembrete:self.editLembreteTipo.text];
        loadNotify = YES;
    }else if (textField == self.editVeterinario){
        [vacina setCVeterinario:self.editVeterinario.text];
    }else if (textField == self.editNotas){
        [vacina setCObs:self.editNotas.text];
    }
    
    [vacina setUpdatedAt:[NSDate date]];
    [MPCoreDataService saveContext];
    if (loadAll) {
        [[MPCoreDataService shared] loadAllPets];
    }
    
    if (loadNotify) {
        [[MPLembretes shared] scheduleNotification:vacina];
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: { return NSLS(@"Selo do Fabricante"); }
            break;
        case 1: { return NSLS(@"Data e Hora"); }
            break;
        case 2: { return NSLS(@"Lembrete Revacina"); }
            break;
        case 3: { return NSLS(@"Veterinário e Notas"); }
            break;
    }
    
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0: { return NSLS(@"Toque na foto para editar ou para mostrar em tela cheia"); }
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
    return [[MPLembretes shared] arrayLembretes].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[MPLembretes shared] arrayLembretes] objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.editLembreteTipo.text = [[[MPLembretes shared] arrayLembretes] objectAtIndex:row];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Deletar"     // Event category (required)
                                                                  action:@"Deletar Vacina"  // Event action (required)
                                                                   label:@"Deletar Vacina"          // Event label
                                                                   value:nil] build]];
            
            [[MPCoreDataService shared] deleteVacinaSelected];
            [self.navigationController popViewControllerAnimated:YES];
            
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
        }else if(buttonIndex == 2){
            Vacina *vacina = [[MPCoreDataService shared] vacinaSelected];
            [[MPCoreDataService shared] setPhotoSelected:[vacina getFotoCompleta]];
            [self performSegueWithIdentifier:@"photoViewController" sender:nil];
        }
    }
}

#pragma mark UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *pickedPhoto = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *resizedPhoto = [MPLibrary imageWithoutCutsWithImage:pickedPhoto widthBased:kMAX_PHOTO_SIZE];
	
    Vacina *vacina = [[MPCoreDataService shared] vacinaSelected];
    [vacina setCSelo:UIImageJPEGRepresentation(resizedPhoto, 1.0)];
    
    [self.imageFoto setImage:[vacina getFoto]];
    
    [vacina setUpdatedAt:[NSDate date]];
    [MPCoreDataService saveContext];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Fotos"     // Event category (required)
                                                          action:@"Foto Vacina"  // Event action (required)
                                                           label:@"Foto Vacina"          // Event label
                                                           value:nil] build]];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
