//
//  UIFlatColor.m
//  TheIncrediblePuzzle
//
//  Created by Henrique Morbin on 13/07/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "UIFlatColor.h"

/*
// Turquoise rgb(26, 188, 156)
// GreenSea rgb(22, 160, 133)
// SunFlower rgb(241, 196, 15)
// Orange rgb(243, 156, 18)
// Emerald rgb(46, 204, 113)
// Nephritis rgb(39, 174, 96)
// Carrot rgb(230, 126, 34)
// Pumpkin rgb(211, 84, 0)
// PeterRiver rgb(52, 152, 219)
// BelizeHole rgb(41, 128, 185)
// Alizarin rgb(231, 76, 60)
// Pomegranate rgb(192, 57, 43)
// Amethyst rgb(155, 89, 182)
// Wisteria rgb(142, 68, 173)
// Clouds rgb(236, 240, 241)
// Silver rgb(189, 195, 199)
// WetAsphalt rgb(52, 73, 94)
// MidnightBlue rgb(44, 62, 80)
// Concrete rgb(149, 165, 166)
// Asbestos rgb(127, 140, 141)
 */

@implementation UIFlatColor

#pragma mark - Métodos
+(UIColor *)R:(CGFloat)r G:(CGFloat)g B:(CGFloat)b
{
    return [self colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    UIImage *image = [UIImage imageNamed:@"colorClouds.png"];

	UIGraphicsBeginImageContext(image.size);
    
	[image drawAtPoint:CGPointZero];
    
	CGContextRef ctx = UIGraphicsGetCurrentContext();

    [color setFill];
    
	CGRect fillRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextFillRect(ctx, fillRect);
    
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	return retImage;
}

#pragma mark - Flat Colors
// Flat Colors
// http://flatuicolors.com

// Teal
// Turquoise rgb(26, 188, 156)
+(UIColor *)turquoiseColor     { return [self R:26 G:188 B:156]; }
+(UIColor *)tealTurquoiseColor { return [UIFlatColor turquoiseColor]; }
+(UIImage *)turquoiseImage     { return [UIFlatColor imageWithColor:[UIFlatColor turquoiseColor]]; }

// Teal
// GreenSea rgb(22, 160, 133)
+(UIColor *)greenSeaColor     { return [self R:22 G:160 B:133]; }
+(UIColor *)tealGreenSeaColor { return [UIFlatColor greenSeaColor]; }
+(UIImage *)greenSeaImage     { return [UIFlatColor imageWithColor:[UIFlatColor greenSeaColor]]; }

// Yellow
// SunFlower rgb(241, 196, 15)
+(UIColor *)sunFlowerColor       { return [self R:241 G:196 B:15]; }
+(UIColor *)yellowSunFlowerColor { return [UIFlatColor sunFlowerColor]; }
+(UIImage *)sunFlowerImage       { return [UIFlatColor imageWithColor:[UIFlatColor sunFlowerColor]]; }

// Orange
// Orange rgb(243, 156, 18)
+(UIColor *)orangeColor       { return [self R:243 G:156 B:18]; }
+(UIColor *)orangeOrangeColor { return [UIFlatColor orangeColor]; }
+(UIImage *)orangeImage       { return [UIFlatColor imageWithColor:[UIFlatColor orangeColor]]; }

// Green
// Emerald rgb(46, 204, 113)
+(UIColor *)emeraldColor      { return [self R:46 G:204 B:113]; }
+(UIColor *)greenEmeraldColor { return [UIFlatColor emeraldColor]; }
+(UIImage *)emeraldImage      { return [UIFlatColor imageWithColor:[UIFlatColor emeraldColor]]; }

// Green
// Nephritis rgb(39, 174, 96)
+(UIColor *)nephritisColor      { return [self R:39 G:174 B:96]; }
+(UIColor *)greenNephritisColor { return [UIFlatColor nephritisColor]; }
+(UIImage *)nephritisImage      { return [UIFlatColor imageWithColor:[UIFlatColor nephritisColor]]; }

// Orange
// Carrot rgb(230, 126, 34)
+(UIColor *)carrotColor       { return [self R:230 G:126 B:34]; }
+(UIColor *)OrangeCarrotColor { return [UIFlatColor carrotColor]; }
+(UIImage *)carrotImage       { return [UIFlatColor imageWithColor:[UIFlatColor carrotColor]]; }

// Orange
// Pumpkin rgb(211, 84, 0)
+(UIColor *)pumpkinColor       { return [self R:211 G:84 B:0]; }
+(UIColor *)orangePumpkinColor { return [UIFlatColor pumpkinColor]; }
+(UIImage *)pumpkinImage       { return [UIFlatColor imageWithColor:[UIFlatColor pumpkinColor]]; }

// Blue
// PeterRiver rgb(52, 152, 219)
+(UIColor *)peterRiverColor       { return [self R:52 G:152 B:219]; }
+(UIColor *)bluePeterRiverColor   { return [UIFlatColor peterRiverColor]; }
+(UIImage *)peterRiverImage       { return [UIFlatColor imageWithColor:[UIFlatColor peterRiverColor]]; }

// Blue
// BelizeHole rgb(41, 128, 185)
+(UIColor *)belizeHoleColor       { return [self R:41 G:128 B:185]; }
+(UIColor *)blueBelizeHoleColor   { return [UIFlatColor belizeHoleColor]; }
+(UIImage *)belizeHoleImage       { return [UIFlatColor imageWithColor:[UIFlatColor belizeHoleColor]]; }

// Red
// Alizarin rgb(231, 76, 60)
+(UIColor *)alizarinColor      { return [self R:231 G:76 B:60]; }
+(UIColor *)redAlizarinColor   { return [UIFlatColor alizarinColor]; }
+(UIImage *)alizarinImage      { return [UIFlatColor imageWithColor:[UIFlatColor alizarinColor]]; }

// Red
// Pomegranate rgb(192, 57, 43)
+(UIColor *)pomegranateColor      { return [self R:192 G:57 B:43]; }
+(UIColor *)redPomegranateColor   { return [UIFlatColor pomegranateColor]; }
+(UIImage *)pomegranateImage      { return [UIFlatColor imageWithColor:[UIFlatColor pomegranateColor]]; }

// Purple
// Amethyst rgb(155, 89, 182)
+(UIColor *)amethystColor         { return [self R:155 G:89 B:182]; }
+(UIColor *)purpleAmethystColor   { return [UIFlatColor amethystColor]; }
+(UIImage *)amethystImage         { return [UIFlatColor imageWithColor:[UIFlatColor amethystColor]]; }

// Purple
// Wisteria rgb(142, 68, 173)
+(UIColor *)wisteriaColor         { return [self R:142 G:68 B:173]; }
+(UIColor *)purpleWisteriaColor   { return [UIFlatColor wisteriaColor]; }
+(UIImage *)wisteriaImage         { return [UIFlatColor imageWithColor:[UIFlatColor wisteriaColor]]; }

// Soft Gray
// Clouds rgb(236, 240, 241)
+(UIColor *)cloudsColor         { return [self R:236 G:240 B:241]; }
+(UIColor *)grayCloudsColor     { return [UIFlatColor cloudsColor]; }
+(UIImage *)cloudsImage         { return [UIFlatColor imageWithColor:[UIFlatColor cloudsColor]]; }

// Soft Gray
// Silver rgb(189, 195, 199)
+(UIColor *)silverColor         { return [self R:189 G:195 B:199]; }
+(UIColor *)graySilverColor     { return [UIFlatColor silverColor]; }
+(UIImage *)silverImage         { return [UIFlatColor imageWithColor:[UIFlatColor silverColor]]; }

// Dark Blue
// WetAsphalt rgb(52, 73, 94)
+(UIColor *)wetAsphaltColor         { return [self R:52 G:73 B:94]; }
+(UIColor *)blueWetAsphaltColor     { return [UIFlatColor wetAsphaltColor]; }
+(UIImage *)wetAsphaltImage         { return [UIFlatColor imageWithColor:[UIFlatColor wetAsphaltColor]]; }

// Dark Blue
// MidnightBlue rgb(44, 62, 80)
+(UIColor *)midnightBlueColor         { return [self R:44 G:62 B:80]; }
+(UIColor *)blueMidnightBlueColor     { return [UIFlatColor midnightBlueColor]; }
+(UIImage *)midnightBlueImage         { return [UIFlatColor imageWithColor:[UIFlatColor midnightBlueColor]]; }

// Dark Gray
// Concrete rgb(149, 165, 166)
+(UIColor *)concreteColor { return [self R:149 G:165 B:166]; }
+(UIColor *)grayConcreteColor     { return [UIFlatColor concreteColor]; }
+(UIImage *)concreteImage         { return [UIFlatColor imageWithColor:[UIFlatColor concreteColor]]; }

// Dark Gray
// Asbestos rgb(127, 140, 141)
+(UIColor *)asbestosColor { return [self R:127 G:140 B:141]; }
+(UIColor *)grayAsbestosColor     { return [UIFlatColor asbestosColor]; }
+(UIImage *)asbestosImage         { return [UIFlatColor imageWithColor:[UIFlatColor asbestosColor]]; }

@end
