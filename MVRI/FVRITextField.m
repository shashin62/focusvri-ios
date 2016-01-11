//
//  FVRITextField.m
//  MVRI
//
//  Created by Murali Gorantla on 12/08/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import "FVRITextField.h"

@implementation FVRITextField

- (void)commonInit
{
    if (self) {
        //self.delegate = self;
        if ([self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            UIColor *color = [UIColor blackColor];
            self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{
                                                                                                                  NSForegroundColorAttributeName: color,NSFontAttributeName : [UIFont boldSystemFontOfSize:14.0]
                                                                                                                  }];
        } else {
            NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
            // TODO: Add fall-back code to set placeholder color.
        }
        self.layer.cornerRadius = 1.0f;
        self.layer.masksToBounds = YES;
//        self.layer.borderWidth = 2.0f;
//        self.layer.borderColor = [[UIColor blackColor] CGColor];
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [[UIColor colorWithRed:144.0f/255.0f green:148.0f/255.0f blue:151.0f/255.0f alpha:1.0f] CGColor];
        
//        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 45)];
//        self.leftView = paddingView;
//        self.leftViewMode = UITextFieldViewModeAlways;
//        self.autocorrectionType = UITextAutocorrectionTypeNo;
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"downArrow"]];
//        UIView *rightPaddingForTextField = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 24)];
//        [rightPaddingForTextField addSubview:imageView];
//        self.rightViewMode = UITextFieldViewModeAlways;
//        self.rightView = rightPaddingForTextField;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
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
