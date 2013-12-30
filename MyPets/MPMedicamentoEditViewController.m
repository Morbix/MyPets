//
//  MPMedicamentoEditViewController.m
//  MyPets
//
//  Created by HP Developer on 25/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPMedicamentoEditViewController.h"
#import "MPCoreDataService.h"
#import "MPLibrary.h"
#import "MPLembretes.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface MPMedicamentoEditViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@property (weak, nonatomic) IBOutlet UITextField *editMedicamento;
@property (weak, nonatomic) IBOutlet UITextField *editDose;
@property (weak, nonatomic) IBOutlet UITextField *editData;
@property (weak, nonatomic) IBOutlet UITextField *editHora;
@property (weak, nonatomic) IBOutlet UITextField *editLembreteTipo;
@property (weak, nonatomic) IBOutlet UITextField *editNotas;

@end

@implementation MPMedicamentoEditViewController

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
    
    self.editMedicamento.placeholder  = NSLS(@"placeholderPetMedicamento");
    self.editDose.placeholder         = NSLS(@"placeholderDose");
    self.editData.placeholder         = NSLS(@"placeholderPetData");
    self.editHora.placeholder         = NSLS(@"placeholderPetHora");
    self.editLembreteTipo.placeholder = NSLS(@"placeholderLembrete");
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
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Medicamento Edit Screen"];
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
    if ([[MPCoreDataService shared] medicamentoSelected]) {
        Medicamento *medicamento = [[MPCoreDataService shared] medicamentoSelected];
        
        
        if (medicamento.cData) {
            self.editData.text = [MPLibrary date:medicamento.cData
                                        toFormat:NSLS(@"dd.MM.yyyy")];
            self.editHora.text = [MPLibrary date:medicamento.cData
                                        toFormat:NSLS(@"hh:mm a")];
        }
        
        self.editMedicamento.text  = medicamento.cNome;
        self.editDose.text         = medicamento.cDose;
        self.editLembreteTipo.text = medicamento.cLembrete;
        self.editNotas.text        = medicamento.cObs;
    }
}

- (void)carregarTeclados
{
    Medicamento *medicamento = nil;
    if ([[MPCoreDataService shared] medicamentoSelected]) {
        medicamento = [[MPCoreDataService shared] medicamentoSelected];
    }
    
    UITextField *__editMedicamento = self.editMedicamento;
    [self.editMedicamento setInputAccessoryView:[self returnToolBarToDismiss:&__editMedicamento]];
    UITextField *__editDose = self.editDose;
    [self.editDose setInputAccessoryView:[self returnToolBarToDismiss:&__editDose]];
    UITextField *__editData = self.editData;
    [self.editData setInputAccessoryView:[self returnToolBarToDismiss:&__editData]];
    UITextField *__editHora = self.editHora;
    [self.editHora setInputAccessoryView:[self returnToolBarToDismiss:&__editHora]];
    UITextField *__editLembreteTipo = self.editLembreteTipo;
    [self.editLembreteTipo setInputAccessoryView:[self returnToolBarToDismiss:&__editLembreteTipo]];
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
    if (medicamento) {
        [datePicker1 setDate:medicamento.cData ? medicamento.cData : [NSDate date]];
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
    if (medicamento) {
        [datePicker2 setDate:medicamento.cData ? medicamento.cData : [NSDate date]];
    }else{
        [datePicker2 setDate:[NSDate date]];
    }
    [self.editHora setInputAccessoryView:[self returnToolBarToDismiss:&__editHora]];
    [self.editHora setInputView:datePicker2];
    
    
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
    NSString *title = [NSString stringWithFormat:@"%@ %@?",NSLS(@"Deseja apagar"),NSLS(@"Medicamento")];
    
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
    }
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
    Medicamento *medicamento = [[MPCoreDataService shared] medicamentoSelected];
    BOOL loadAll = FALSE;
    BOOL loadNotify = FALSE;
    
    if (textField == self.editData) {
        [medicamento setCData:[(UIDatePicker *)self.editData.inputView date]];
        [(UIDatePicker *)self.editHora.inputView setDate:medicamento.cData];
        loadNotify = YES;
    }else if (textField == self.editHora){
        [medicamento setCData:[(UIDatePicker *)self.editHora.inputView date]];
        [(UIDatePicker *)self.editData.inputView setDate:medicamento.cData];
        loadNotify = YES;
    }else if (textField == self.editLembreteTipo){
        [medicamento setCLembrete:self.editLembreteTipo.text];
        loadNotify = YES;
    }else if (textField == self.editNotas){
        [medicamento setCObs:self.editNotas.text];
    }else if (textField == self.editMedicamento){
        [medicamento setCNome:self.editMedicamento.text];
        loadNotify = YES;
    }else if (textField == self.editDose){
        [medicamento setCDose:self.editDose.text];
    }
    
    [MPCoreDataService saveContext];
    if (loadAll) {
        [[MPCoreDataService shared] loadAllPets];
    }
    
    if (loadNotify) {
        [[MPLembretes shared] scheduleNotification:medicamento];
    }
    
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: { return NSLS(@"Medicamento e Dose"); }
            break;
        case 1: { return NSLS(@"Data e Hora"); }
            break;
        case 2: { return NSLS(@"Lembrete"); }
            break;
        case 3: { return NSLS(@"Notas"); }
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
                                                                  action:@"Deletar Medicamento"  // Event action (required)
                                                                   label:@"Deletar Medicamento"          // Event label
                                                                   value:nil] build]];
            
            [[MPCoreDataService shared] deleteMedicamentoSelected];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
}

@end
