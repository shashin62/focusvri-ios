//
//  MVRIInterPretersTableViewCell.h
//  MVRI
//
//  Created by Murali Gorantla on 08/08/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVRIInterPretersTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *interpreterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatharImageView;

@end
