//
//  MVRIActivityTableViewCell.h
//  MVRI
//
//  Created by Murali Gorantla on 02/09/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVRIActivityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *activityDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *claimantName;
@property (weak, nonatomic) IBOutlet UILabel *activityTotalTimeLabel;

@end
