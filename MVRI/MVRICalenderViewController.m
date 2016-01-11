//
//  MVRICalenderViewController.m
//  MVRI
//
//  Created by mac on 11/26/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "MVRICalenderViewController.h"
#import "ASIFormDataRequest.h"
#import "MVRIClaimsCell.h"

@interface MVRICalenderViewController ()
-(BOOL) parseData:(NSData*)responseData;
@end

@implementation MVRICalenderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark View Lifecycle
- (void) viewDidLoad{
	[super viewDidLoad];
	self.title = NSLocalizedString(@"Month Grid", @"");
	[self.monthView selectDate:[NSDate date]];
    NSLog(@"tableview height: %f", self.view.frame.size.height);
//    CGRect newTableFrame = CGRectMake(_cv.tableView.frame.origin.x, _cv.tableView.frame.origin.y, _cv.tableView.frame.size.width, _cv.tableView.frame.size.height - [self. ].frame.origin.y);
//    [_cv.tableView setFrame:newTableFrame];
}



#pragma mark MonthView Delegate & DataSource
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate{
	[self generateDataForStartDate:startDate endDate:lastDate];
//    [self generateRandomDataForStartDate:startDate endDate:lastDate];
	return self.dataArray;
}
- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date{
    NSDateComponents *info = [date dateComponentsWithTimeZone:self.monthView.timeZone];
    
    NSDate *_manupulatedDate = [NSDate dateWithDateComponents:info];
	NSLog(@"Date Selected: %@",_manupulatedDate);
	[self.tableView reloadData];
}
- (void) calendarMonthView:(TKCalendarMonthView*)mv monthDidChange:(NSDate*)d animated:(BOOL)animated{
	[super calendarMonthView:mv monthDidChange:d animated:animated];
	[self.tableView reloadData];
}

    


#pragma mark UITableView Delegate & DataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.monthView dateSelected] != nil) {
        NSDateComponents *info = [[self.monthView dateSelected] dateComponentsWithTimeZone:self.monthView.timeZone];
        info.hour = 0;
        info.minute = 0;
        info.second = 0;
        
        NSDate *_manupulatedDate = [NSDate dateWithDateComponents:info];
        NSArray *ar = self.dataDictionary[_manupulatedDate];
        if(ar == nil) return 0;
        return [ar count];
    }
    return 0;
   
}
- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
        
        //claim label
        UILabel *_claim = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, cell.contentView.frame.size.width-20.0, 21.0)];
        [_claim setFont:[UIFont systemFontOfSize:13.0]];
        [_claim setTextColor:[UIColor redColor]];
        [_claim setTextAlignment:NSTextAlignmentLeft];
        [_claim setTag:1];
        [cell addSubview:_claim];
        
        //start label
        UILabel *_start = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 20.0, cell.contentView.frame.size.width-20.0, 21.0)];
        [_start setFont:[UIFont systemFontOfSize:13.0]];
        [_start setTextColor:[UIColor blackColor]];
        [_start setTextAlignment:NSTextAlignmentLeft];
        [_start setTag:2];
        [cell addSubview:_start];
        
        //lang label
        UILabel *_lang = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 40.0, cell.contentView.frame.size.width - 20.0, 21.0)];
        [_lang setFont:[UIFont systemFontOfSize:13.0]];
        [_lang setTextColor:[UIColor blackColor]];
        [_lang setTextAlignment:NSTextAlignmentLeft];
        [_lang setTag:3];
        [cell addSubview:_lang];
        
        
    }
    
    
	NSDateComponents *info = [[self.monthView dateSelected] dateComponentsWithTimeZone:self.monthView.timeZone];
    info.hour = 0;
    info.minute = 0;
    info.second = 0;
    
    NSDate *_manupulatedDate = [NSDate dateWithDateComponents:info];
	NSDictionary *_currentObject = [(NSMutableArray *)self.dataDictionary[_manupulatedDate] objectAtIndex:indexPath.row];
//	cell.textLabel.text = ar[indexPath.row];
	
    // Configure the cell...
    
    UILabel *_claim = (UILabel*)[cell viewWithTag:1];
    [_claim setText:[NSString stringWithFormat:@"Claim :%@, %@, %@", [_currentObject objectForKey:@"claimno"], [_currentObject objectForKey:@"interpreterName"], [_currentObject objectForKey:@"clientName"] ]];
    
    UILabel *_start = (UILabel*)[cell viewWithTag:2];
    [_start setText:[NSString stringWithFormat:@"Start :%@", [_currentObject objectForKey:@"start"] ]];
    
    UILabel *_lang = (UILabel*)[cell viewWithTag:3];
    [_lang setText:[NSString stringWithFormat:@"Language :%@", [_currentObject objectForKey:@"language"] ]];
   
    
    return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}


- (void) generateRandomDataForStartDate:(NSDate*)start endDate:(NSDate*)end{
	// this function sets up dataArray & dataDictionary
	// dataArray: has boolean markers for each day to pass to the calendar view (via the delegate function)
	// dataDictionary: has items that are associated with date keys (for tableview)
	
	
	NSLog(@"Delegate Range: %@ %@ %d",start,end,[start daysBetweenDate:end]);
	
	self.dataArray = [NSMutableArray array];
	self.dataDictionary = [NSMutableDictionary dictionary];
	
	NSDate *d = start;
	while(YES){
		
		NSInteger r = arc4random();
		if(r % 3==1){
			(self.dataDictionary)[d] = @[@"Item one",@"Item two",@"Item three",@"Item four",@"Item five",@"Item six"];
			[self.dataArray addObject:@YES];
			
		}else if(r%4==1){
			(self.dataDictionary)[d] = @[@"Item one"];
			[self.dataArray addObject:@YES];
			
		}else
			[self.dataArray addObject:@NO];
		
		
		NSDateComponents *info = [d dateComponentsWithTimeZone:self.monthView.timeZone];
		info.day++;
		d = [NSDate dateWithDateComponents:info];
		if([d compare:end]==NSOrderedDescending) break;
	}
	
}

- (void) generateDataForStartDate:(NSDate*)start endDate:(NSDate*)end{
    
    
    NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/GetAppointmentsRange?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    //NSString *_urlString = [NSString stringWithFormat:@"http://mobilevri.com/api/vri/GetAppointmentsRange?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    NSURL *url = [NSURL URLWithString:_urlString];
    
    //fetch current system date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/d/yyyy hh:mma"];//Wed, Dec 14 2011 1:50 PM
    NSString *str_date = [dateFormat stringFromDate:start];
    NSLog(@"str_date = %@",str_date);
    
    
    NSString *end_date = [dateFormat stringFromDate:end];
    NSLog(@"end_date = %@",end_date);
    
    //create form request for fetching appointments
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:str_date forKey:@"fd"];
    [request setPostValue:end_date forKey:@"td"];
    [request start];
    
    NSError *error = [request error];
    if (!error) {
        
        //process the reply
        NSString *response = [request responseString];
        NSLog(@"all appointments: %@", response);
        [self parseData:[response dataUsingEncoding:NSUTF8StringEncoding]];
        
        //reset arrays
        self.dataArray = [NSMutableArray array];
        self.dataDictionary = [NSMutableDictionary dictionary];
        
        NSLog(@"difference:%d",[start daysBetweenDate:end]);
        
        for (int i = 0; i<[start daysBetweenDate:end]; i++) {
            [self.dataArray addObject:@NO];
        }
        
        
        for (NSDictionary *_tempDict in _allResults) {
            //        [_clientList addObject:[[NSDictionary alloc] initWithDictionary:_tempDict copyItems:YES]];
            
            //convert string to nsdate
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"M/d/yyyy hh:mm:ssa"];
//            NSLog(@"----start---------d:%@", [_tempDict valueForKey:@"start"]);
            NSDate *myDate = [df dateFromString: [_tempDict valueForKey:@"start"]];
            
            NSDateComponents *info = [myDate dateComponentsWithTimeZone:self.monthView.timeZone];
            info.hour = 0;
            info.minute = 0;
            info.second = 0;
            
            NSDate *_manupulatedDate = [NSDate dateWithDateComponents:info];
            
            if ((self.dataDictionary) [_manupulatedDate] == Nil) {
                (self.dataDictionary) [_manupulatedDate] = [NSMutableArray array];
            }
            
           
            
//            [((NSMutableArray*) (self.dataDictionary) [_manupulatedDate]) addObject:[NSString stringWithFormat:@"Claim :%@, %@, %@", [_tempDict objectForKey:@"claimno"], [_tempDict objectForKey:@"interpreterName"], [_tempDict objectForKey:@"clientName"] ]];
            
            [((NSMutableArray*) (self.dataDictionary) [_manupulatedDate]) addObject:_tempDict];
            
            int diffInDays = [start daysBetweenDate:_manupulatedDate];
            [_dataArray replaceObjectAtIndex:diffInDays withObject:@YES];
            
        }
        //    [_clientList addObjectsFromArray:latestLoans];
    }

    
    
    
	// this function sets up dataArray & dataDictionary
	// dataArray: has boolean markers for each day to pass to the calendar view (via the delegate function)
	// dataDictionary: has items that are associated with date keys (for tableview)
	
	
//	NSLog(@"Delegate Range: %@ %@ %d",start,end,[start daysBetweenDate:end]);
//	
//	self.dataArray = [NSMutableArray array];
//	self.dataDictionary = [NSMutableDictionary dictionary];
//	
//	NSDate *d = start;
//	while(YES){
//		
//		NSInteger r = arc4random();
//		if(r % 3==1){
//			(self.dataDictionary)[d] = [NSMutableArray arrayWithObjects:@"Item one",@"Item one",@"Item oneItem one",@"Item one", nil];
//			[self.dataArray addObject:@YES];
//			
//		}else if(r%4==1){
//			(self.dataDictionary)[d] = @[@"Item one"];
//			[self.dataArray addObject:@YES];
//			
//		}else
//			[self.dataArray addObject:@NO];
//		
//		
//		NSDateComponents *info = [d dateComponentsWithTimeZone:self.monthView.timeZone];
//		info.day++;
//		d = [NSDate dateWithDateComponents:info];
//        NSLog(@"d:%@", [d description]);
//		if([d compare:end]==NSOrderedDescending) break;
//	}
	
}

-(BOOL) parseData:(NSData*)responseData{
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:NSJSONReadingMutableContainers
                          error:&error];
    if (error) {
        return false;
    }
    
    _allResults = [json objectForKey:@"result"]; //2
    
    //    NSLog(@"loans: %@", json); //3
    //    NSLog(@"results : %@", latestLoans);
    NSLog(@"success : %@", [json objectForKey:@"success"]);
    
    
    
    return true;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
