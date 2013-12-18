//
//  MPVacinaEditViewController.m
//  MyPets
//
//  Created by HP Developer on 17/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPVacinaEditViewController.h"

@interface MPVacinaEditViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)barButtonRightTouched:(id)sender
{
    
}

#pragma mark - UITableViewDelegate and UITableViewDataSource


@end
