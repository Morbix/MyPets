//
//  MPPhotoViewController.m
//  MyPets
//
//  Created by HP Developer on 10/03/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MPPhotoViewController.h"
#import "MPCoreDataService.h"

@interface MPPhotoViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollZoom;
@property (weak, nonatomic) IBOutlet UIImageView *imagePhoto;
@end

@implementation MPPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.scrollZoom setMaximumZoomScale:3.0];
    [self.scrollZoom setMinimumZoomScale:0.5];
    
    if ([[MPCoreDataService shared] photoSelected]) {
        [self.imagePhoto setImage:[[MPCoreDataService shared] photoSelected]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imagePhoto;
}

@end
