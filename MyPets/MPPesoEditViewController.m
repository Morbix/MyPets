//
//  MPPesoEditViewController.m
//  MyPets
//
//  Created by HP Developer on 12/01/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPPesoEditViewController.h"
#import "MPCoreDataService.h"
#import "MPLibrary.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "MPAds.h"
#import <iAd/iAd.h>

@interface MPPesoEditViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
    MPAds *ads;
}


@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@property (weak, nonatomic) IBOutlet UITextField *editData;
@property (weak, nonatomic) IBOutlet UITextField *editPeso;
@property (weak, nonatomic) IBOutlet UITextField *editNotas;

@end

@implementation MPPesoEditViewController

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
    self.editPeso.placeholder         = NSLS(@"placeholderPeso");
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
    
    if ([MPTargets targetAds]) {
        self.canDisplayBannerAds = YES;
        ads = [[MPAds alloc] initWithScrollView:self.tableView viewController:self admobID:@"ca-app-pub-8687233994493144/9185108364"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Peso Edit Screen"];
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
    if ([[MPCoreDataService shared] pesoSelected]) {
        Peso *peso = [[MPCoreDataService shared] pesoSelected];
        
        
        if (peso.cData) {
            self.editData.text = [MPLibrary date:peso.cData
                                        toFormat:NSLS(@"dd.MM.yyyy")];
        }
        
        self.editPeso.text         = [NSString stringWithFormat:@"%.2f",peso.cPeso?peso.cPeso.floatValue : 0.0f];
        self.editNotas.text        = peso.cObs;
    }
}

- (void)carregarTeclados
{
    Peso *peso = nil;
    if ([[MPCoreDataService shared] pesoSelected]) {
        peso = [[MPCoreDataService shared] pesoSelected];
    }
    
    UITextField *__editPeso = self.editPeso;
    [self.editPeso setInputAccessoryView:[self returnToolBarToDismiss:&__editPeso]];
    UITextField *__editData = self.editData;
    [self.editData setInputAccessoryView:[self returnToolBarToDismiss:&__editData]];
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
    if (peso) {
        [datePicker1 setDate:peso.cData ? peso.cData : [NSDate date]];
    }else{
        [datePicker1 setDate:[NSDate date]];
    }
    [self.editData setInputAccessoryView:[self returnToolBarToDismiss:&__editData]];
    [self.editData setInputView:datePicker1];
    
    
    UIPickerView *pickerViewPeso = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [pickerViewPeso setDelegate:self];
    [pickerViewPeso setDataSource:self];
    [pickerViewPeso setTag:1];
    [self.editPeso setInputAccessoryView:[self returnToolBarToDismiss:&__editPeso]];
    [self.editPeso setInputView:pickerViewPeso];
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
    NSString *title = [NSString stringWithFormat:@"%@ %@?",NSLS(@"Deseja apagar"),NSLS(@"Peso")];
    
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
    Peso *peso = [[MPCoreDataService shared] pesoSelected];
    BOOL loadAll = FALSE;
    
    if (textField == self.editData) {
        [peso setCData:[(UIDatePicker *)self.editData.inputView date]];
    }else if (textField == self.editNotas){
        [peso setCObs:self.editNotas.text];
    }else if (textField == self.editPeso){
        [peso setCPeso:[NSNumber numberWithFloat:self.editPeso.text.floatValue]];
        NSLog(@"peso %@",peso.cPeso.description);
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
        case 0: { return NSLS(@"Data"); }
            break;
        case 1: { return NSLS(@"Peso"); }
            break;
        case 2: { return NSLS(@"Notas"); }
            break;
    }
    
    return @"";
}

#pragma mark - UIPickerViewDelegate and UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 100;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 1 && row < 10) {
        return [NSString stringWithFormat:@"0%d",(int)row];
    }
    return [NSString stringWithFormat:@"%d",(int)row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView selectedRowInComponent:1] < 10) {
        self.editPeso.text = [NSString stringWithFormat:@"%d.0%d", (int)[pickerView selectedRowInComponent:0], (int)[pickerView selectedRowInComponent:1]];
    }else{
        self.editPeso.text = [NSString stringWithFormat:@"%d.%d", (int)[pickerView selectedRowInComponent:0], (int)[pickerView selectedRowInComponent:1]];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Deletar"     // Event category (required)
                                                                  action:@"Deletar Peso"  // Event action (required)
                                                                   label:@"Deletar Peso"          // Event label
                                                                   value:nil] build]];
            
            [[MPCoreDataService shared] deletePesoSelected];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
}
@end
