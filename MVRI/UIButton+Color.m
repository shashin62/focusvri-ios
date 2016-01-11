//
//  UIButton+Color.m
//  MVRI
//
//  Created by Murali Gorantla on 02/10/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import "UIButton+Color.h"

@implementation UIButton (Color)

- (void)setColor:(UIColor *)color forState:(UIControlState)state
{
    UIView *colorView = [[UIView alloc] initWithFrame:self.frame];
    colorView.backgroundColor = color;
    
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setBackgroundImage:colorImage forState:state];
}

//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//    
//    if (selected) {
//        self.backgroundColor = [UIColor FVRIGreenColor];
//    }
//    
//}

@end
