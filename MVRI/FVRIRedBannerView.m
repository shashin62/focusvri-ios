//
//  FVRIRedBannerView.m
//  MVRI
//
//  Created by Murali Gorantla on 27/09/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import "FVRIRedBannerView.h"

@implementation FVRIRedBannerView

- (void)commonInit
{
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:197.0f/255.0f green:34.0f/255.0f blue:21.0f/255.0f alpha:1.0f];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
