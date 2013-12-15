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

@interface MPPetEditViewController ()  <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>


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
#warning O que falta?
    //Alterar Valor quando edita os textfields customizados
    //Salvar o pet
    //A edicao da foto

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
        [datePicker setDate:animal.cDataNascimento];
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

}

- (IBAction)datePickerValueChanged:(id)sender
{
    
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



@end
