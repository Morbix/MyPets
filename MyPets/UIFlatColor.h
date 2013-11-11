//
//  UIFlatColor.h
//  TheIncrediblePuzzle
//
//  Created by Henrique Morbin on 13/07/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIFlatColor : UIColor

+ (UIColor *)R:(CGFloat)r G:(CGFloat)g B:(CGFloat)b;
+ (UIImage *)imageWithColor:(UIColor *)color;

#pragma mark - UIFlatColor
// Flat Colors
// http://flatuicolors.com

// Teal
// Turquoise rgb(26, 188, 156)
+(UIColor *)turquoiseColor;
+(UIColor *)tealTurquoiseColor;
+(UIImage *)turquoiseImage;

// Teal
// GreenSea rgb(22, 160, 133)
+(UIColor *)greenSeaColor;
+(UIColor *)tealGreenSeaColor;
+(UIImage *)greenSeaImage;

// Yellow
// SunFlower rgb(241, 196, 15)
+(UIColor *)sunFlowerColor;
+(UIColor *)yellowSunFlowerColor;
+(UIImage *)sunFlowerImage;

// Orange
// Orange rgb(243, 156, 18)
+(UIColor *)orangeColor;
+(UIColor *)orangeOrangeColor;
+(UIImage *)orangeImage;

// Green
// Emerald rgb(46, 204, 113)
+(UIColor *)emeraldColor;
+(UIColor *)greenEmeraldColor;
+(UIImage *)emeraldImage;

// Green
// Nephritis rgb(39, 174, 96)
+(UIColor *)nephritisColor;
+(UIColor *)greenNephritisColor;
+(UIImage *)nephritisImage;

// Orange
// Carrot rgb(230, 126, 34)
+(UIColor *)carrotColor;
+(UIColor *)OrangeCarrotColor;
+(UIImage *)carrotImage;

// Orange
// Pumpkin rgb(211, 84, 0)
+(UIColor *)pumpkinColor;
+(UIColor *)orangePumpkinColor;
+(UIImage *)pumpkinImage;

// Blue
// PeterRiver rgb(52, 152, 219)
+(UIColor *)peterRiverColor;
+(UIColor *)bluePeterRiverColor;
+(UIImage *)peterRiverImage;

// Blue
// BelizeHole rgb(41, 128, 185)
+(UIColor *)belizeHoleColor;
+(UIColor *)blueBelizeHoleColor;
+(UIImage *)belizeHoleImage;

// Red
// Alizarin rgb(231, 76, 60)
+(UIColor *)alizarinColor;
+(UIColor *)redAlizarinColor;
+(UIImage *)alizarinImage;

// Red
// Pomegranate rgb(192, 57, 43)
+(UIColor *)pomegranateColor;
+(UIColor *)redPomegranateColor;
+(UIImage *)pomegranateImage;

// Purple
// Amethyst rgb(155, 89, 182)
+(UIColor *)amethystColor;
+(UIColor *)purpleAmethystColor;
+(UIImage *)amethystImage;

// Purple
// Wisteria rgb(142, 68, 173)
+(UIColor *)wisteriaColor;
+(UIColor *)purpleWisteriaColor;
+(UIImage *)wisteriaImage;

// Soft Gray
// Clouds rgb(236, 240, 241)
+(UIColor *)cloudsColor;
+(UIColor *)grayCloudsColor;
+(UIImage *)cloudsImage;

// Soft Gray
// Silver rgb(189, 195, 199)
+(UIColor *)silverColor;
+(UIColor *)graySilverColor;
+(UIImage *)silverImage;

// Dark Blue
// WetAsphalt rgb(52, 73, 94)
+(UIColor *)wetAsphaltColor;
+(UIColor *)blueWetAsphaltColor;
+(UIImage *)wetAsphaltImage;

// Dark Blue
// MidnightBlue rgb(44, 62, 80)
+(UIColor *)midnightBlueColor;
+(UIColor *)blueMidnightBlueColor;
+(UIImage *)midnightBlueImage;

// Dark Gray
// Concrete rgb(149, 165, 166)
+(UIColor *)concreteColor;
+(UIColor *)grayConcreteColor;
+(UIImage *)concreteImage;

// Dark Gray
// Asbestos rgb(127, 140, 141)
+(UIColor *)asbestosColor;
+(UIColor *)grayAsbestosColor;
+(UIImage *)asbestosImage;

@end
