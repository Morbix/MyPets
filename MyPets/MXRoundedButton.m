//
//  RoundedButton.m
//  Quiz
//
//  Created by HP Developer on 05/03/15.
//  Copyright (c) 2015 HP. All rights reserved.
//

#import "MXRoundedButton.h"

@implementation MXRoundedButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.layer.cornerRadius = 4.0f;
    }
    return self;
}

@end
