//
//  MVRICallActivityTableViewController.m
//  MVRI
//
//  Created by Murali Gorantla on 10/10/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import "MVRICallActivityTableViewController.h"
#import "MVRIActivityTableViewCell.h"
#import "SWRevealViewController.h"


@interface MVRICallActivityTableViewController ()
@property (strong, nonatomic) NSArray *activities;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MVRICallActivityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.tableView.estimatedRowHeight = 73.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [UIColor clearColor];
    UIImage *img = [UIImage imageNamed:@"focus"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [imgView setImage:img];
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imgView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestForAllInterpretersActivities];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)performMenuButtonAction:(id)sender {
    [self.revealViewController revealToggle:sender];
}

#pragma mark - Helper Methods

- (NSDateFormatter *)formatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yy";
        NSTimeZone *utc = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [formatter setTimeZone:utc];
    });
    return formatter;
}

- (void)requestForAllInterpretersActivities {
    NSString *_urlString = [NSString stringWithFormat:@"http://qa.focusvri.com/api/GetActivity/%@",[MVRIGlobalData sharedInstance].userID];
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Token" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    //[request start];
    [request setDelegate:self];
    [request startAsynchronous];
}

#pragma - mark ASIHTTP delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
    self.activities = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:nil];
    [self.tableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"login failed:%@", [error description]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.activities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVRIActivityTableViewCell *cell = (MVRIActivityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"activityIdentifier"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MVRIActivityTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (indexPath.row % 2) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:1.0];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    NSDateFormatter *formatter = [self formatter];
    NSDate *dateTemp = [[NSDate alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    dateTemp = [formatter dateFromString:self.activities[indexPath.row][@"ActivityDate"]];
    [formatter setDateFormat:@"MMM/dd/yyyy"];
    cell.activityDateLabel.text = [formatter stringFromDate:dateTemp];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *startDate = [formatter dateFromString:self.activities[indexPath.row][@"StartTime"]];
    NSDate *endDate = [formatter dateFromString:self.activities[indexPath.row][@"EndTime"]];
    [formatter setDateFormat:@"hh:mm a"];
    cell.activityTimeLabel.text = [NSString stringWithFormat:@"%@ - %@",[formatter stringFromDate:startDate],[formatter stringFromDate:endDate]];
    cell.claimantName.text = [NSString stringWithFormat:@"%@.",self.activities[indexPath.row][@"ClientContactName"]];
    cell.activityTotalTimeLabel.text = self.activities[indexPath.row][@"TotalTime"];
    return cell;

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 73;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
