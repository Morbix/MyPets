//
//  MPLibrary.h
//  MyPets
//
//  Created by Henrique Morbin on 25/10/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPLibrary : NSObject

+ (void)appearanceCustom;
+ (UIView *)getLogoViewForNavigation;
+ (UIView *)getViewWithTitle:(NSString *)title withSize:(float)size;

+ (NSString*)date:(NSDate*)date toFormat:(NSString*)_format;
+ (NSDate *)dateFromRssStringDate:(NSString *)stringDate;
+ (void)sortMutableArray:(NSMutableArray * __strong *)array withAttribute:(NSString*)attr andAscending:(BOOL)ascending;

@end
