//
// SettingsViewController.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

@interface SettingsViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIButton *sidebarButton;
@property (weak, nonatomic) IBOutlet UILabel *user;
-(IBAction)revelMenuPressed:(id)sender;

@end
