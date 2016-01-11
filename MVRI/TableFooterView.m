//
//  TableFooterView.m
//  Treater
//
//  Created by Murali Gorantla on 8/3/15.
//  Copyright (c) 2015 V2 Solutions. All rights reserved.
//

#import "TableFooterView.h"

@implementation TableFooterView

- (void)commonInit
{
    if (self) {
            // Initialization code
        [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], [UITableView class], nil]
         setBackgroundColor:[UIColor colorWithRed:132.0f/255.0f green:186.0f/255.0f blue:86.0f/255.0f alpha:1.0f]];
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
