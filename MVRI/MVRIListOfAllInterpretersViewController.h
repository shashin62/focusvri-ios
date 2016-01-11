//
//  MVRIListOfAllInterpretersViewController.h
//  MVRI
//
//  Created by Murali Gorantla on 08/08/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVRIListOfAllInterpretersViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *interPretersTableView;

- (IBAction)performMenuButtonAction:(id)sender;
- (IBAction)performSeachButtonAction:(id)sender;
@end
