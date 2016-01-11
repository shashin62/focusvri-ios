//
//  TableHeaderView.m
//  Treater
//
//  Created by Murali Gorantla on 8/3/15.
//  Copyright (c) 2015 V2 Solutions. All rights reserved.
//

#import "TableHeaderView.h"

@implementation TableHeaderView

- (void)commonInit
{
    if (self) {
            // Initialization code
        [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], [UITableView class], nil]
         setBackgroundColor: [UIColor colorWithRed:242.0f/255.0f green:247.0f/255.0f blue:250.0f/255.0f alpha:1.0f]];
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
