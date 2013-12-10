//
//  MPLibrary.m
//  MyPets
//
//  Created by Henrique Morbin on 25/10/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPLibrary.h"
#import "UIFlatColor.h"

@implementation MPLibrary

+ (void)appearanceCustom
{
    return;
    //Azul Celeste
    UIColor *navigationColor = [UIColor colorWithRed:0.0f green:153.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    //UIColor *gray = [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0f];
    //UIColor *siemens = [UIColor colorWithRed:8.0f/255.0f green:115.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
    //Cinza escuro
    //UIColor *navigationColor = [UIColor colorWithRed:33.0f/255.0f green:33.0f/255.0f blue:33.0f/255.0f alpha:1.0f];
    
    //[[UINavigationBar appearance] setTintColor:navigationColor];
    [[UIBarButtonItem appearance] setTintColor:navigationColor];
    
    UIImage *navImage = [UIImage imageNamed:@"iPhone_Navigation.png"];
    //UIImage *navImage = [[UIFlatColor orangeImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [[UINavigationBar appearance] setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor],
                                                          UITextAttributeTextColor,
                                                          [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0], UITextAttributeTextShadowColor,
                                                          [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                                          [UIFont boldSystemFontOfSize:18.0f],
                                                          UITextAttributeFont, nil]];
}

+ (UIView *)getLogoViewForNavigation
{
    UIImageView *imageView = [UIImageView new];
    [imageView setImage:[UIImage imageNamed:@"iPhone_Navigation.png"]];
    [imageView setFrame:CGRectMake(0, 0, 320, 44)];
    
    return imageView;
}

+ (UIView *)getViewWithTitle:(NSString *)title withSize:(float)size
{
    UILabel * label = [UILabel new];
    [label setFrame:CGRectMake(0, 0, 320, 0)];
    [label setText:title];
    [label setFont:[UIFont boldSystemFontOfSize:size]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setShadowColor:[UIColor blackColor]];
    [label setShadowOffset:CGSizeMake(0, -0.5)];
    [label setBackgroundColor:[UIColor clearColor]];
    //[label setTextAlignment:NSTextAlignmentLeft];
    
    
    return label;
}

+ (NSString*)date:(NSDate*)date toFormat:(NSString*)_format
{
    NSDateFormatter * format = [[NSDateFormatter alloc] init];
    [format setDateFormat:_format];
    NSString * result = [format stringFromDate:date];
    return result;
}

+ (NSDate *)dateFromRssStringDate:(NSString *)stringDate
{
    NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"EEE, dd MMMM yyyy HH:mm:ss Z"];
    [dateFormatter setLocale:enLocale];
    
    NSDate *data = [dateFormatter dateFromString:stringDate];
    
    return data;
}

+ (void)sortMutableArray:(NSMutableArray * __strong *)array withAttribute:(NSString*)attr andAscending:(BOOL)ascending
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attr ascending:ascending];
    [*array sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

@end
