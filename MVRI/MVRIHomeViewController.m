//
//  MVRIHomeViewController.m
//  MVRI
//
//  Created by mac on 11/18/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "MVRIHomeViewController.h"
#import "SWRevealViewController.h"
#import "ASIFormDataRequest.h"
#import "MVRIGlobalData.h"


static int i=0;

NSString *flgBackgroundAlertShow= @"false";

@interface MVRIHomeViewController ()

@end

@implementation MVRIHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.96f alpha:0.2f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
//    _sidebarButton.target = self.revealViewController;
//    _sidebarButton.action = @selector(revealToggle:);
    
    
    //GetCurrentUserInfo
    NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/getclient?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    
    [self performSelectorInBackground:@selector(longPoll) withObject: nil];
    
    /*for(i=0; i<=10;i++)
    {
    
        [self performSelectorInBackground:@selector(longPoll) withObject: nil];
    
        if (i==10) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Call" message: @"Client is online" delegate: self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            alert.tag = 1;
            [alert show];
        }
    }*/

    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //[request setPostValue:str_date forKey:@"fd"];
    //[request setPostValue:end_date forKey:@"td"];
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [request setRequestMethod:@"Post"];
    [request start];
    
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"Get User: %@", response);
        
        NSData *responseData=[response dataUsingEncoding:NSUTF8StringEncoding];
        //NSLog(@"buffer time: %@", responseData);
        /* NSDictionary *jsonArry = [NSJSONSerialization
         JSONObjectWithData:responseData //1
         
         options:NSJSONReadingMutableContainers
         error:&error];*/
        NSArray *jsonArry = [NSJSONSerialization
                             JSONObjectWithData:responseData //1
                             
                             options:NSJSONReadingMutableContainers
                             error:&error];
        
        
        NSError *jsonError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&jsonError];
 
        NSLog(@"%@",jsonArry);

        [MVRIGlobalData sharedInstance].Firstname = jsonObject[@"FirstName"];
        [MVRIGlobalData sharedInstance].UsrRole = jsonObject[@"UsrRole"];
    
    }
    
    //[_user setText:[NSString stringWithFormat:@"Welcome, %@ (%@)", [MVRIGlobalData sharedInstance].Firstname, [MVRIGlobalData sharedInstance].username]];
    [_user setText:[NSString stringWithFormat:@"Welcome, %@", [MVRIGlobalData sharedInstance].Firstname]];

    // Set the gesture

    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
   }




//Pool

-(void) longPoll {
    
    @autoreleasepool {
        
        NSError* error = nil;
        NSURLResponse* response = nil;
        //NSURL *requestUrl = [NSURL URLWithString: [NSString stringWithFormat:@"%@",appId.text]];
        
        //NSURL *requestUrl = [NSURL URLWithString:@"http://www.mysite.com/pollUrl"];
        
        NSString *requestUrl = [NSString stringWithFormat:@"http://login.mobilevri.com/api/Polling/GetOnlineStatus?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
        //NSString *requestUrl = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/CheckOnlineStatus?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
        NSURL *url = [NSURL URLWithString:requestUrl];
        
     
        
        //NSString *post = @"username=stalin&password=stalin123";
       /* NSString *post = @"apptid=1173";
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding   allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
        
        //NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"key", @"apptid", nil];
        //NSData *postData = [self encodeDictionary:postDict];
        */
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
       [request setHTTPMethod:@"POST"];
       /* [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:postData];
        */
        //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        //[connection start];
        
        
        //NSURLRequest* request = [NSURLRequest requestWithURL:url];
        NSData* responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response error:&error];
       

        [self performSelectorOnMainThread:@selector(dataReceived:)
                               withObject:responseData waitUntilDone:YES];
        
        
        /*NSString *jsonArry = [NSJSONSerialization
                             JSONObjectWithData:responseData //1
                             
                             options:NSJSONReadingMutableContainers
                             error:&error];
        
        NSLog(@"jsonArryNew = %@",jsonArry);*/
        
        //NSLog(@"jsonArry = %@",responseData);
        
      /*
        ASIFormDataRequest *requestNew = [ASIFormDataRequest requestWithURL:url];
        //[request setPostValue:str_date forKey:@"fd"];
        //[requestNew setPostValue:"1105" forKey:@"apptid"];
        //NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [requestNew setRequestMethod:@"Post"];
        [requestNew start];
        
        NSError *errorNew = [requestNew error];
        if (!error) {
            NSString *response = [requestNew responseString];
            NSLog(@"buffer time: %@", response);
            
            NSData *responseDataNew=[response dataUsingEncoding:NSUTF8StringEncoding];
            
            NSArray *jsonArry = [NSJSONSerialization
                                 JSONObjectWithData:responseDataNew //1
                                 
                                 options:NSJSONReadingMutableContainers
                                 error:&error];
            
            NSLog(@"jsonArryNew = %@",jsonArry);
            for(NSDictionary *json in jsonArry)
            {
                if([json[@"mkey"] isEqual: @"PreCallBuffer"])
                {
                    
                    //NSLog(@"mValue : %@", mPreValue);NSLog(@"mValue : %d", [mPreValue intValue]*60);
                }
                else if([json[@"mkey"] isEqual: @"PostCallBuffer"])
                {
                    
                    //NSLog(@"mValue : %@", mPostValue);NSLog(@"mValue : %d", [mPostValue intValue]*60);
                }
            }
        }
        */
        
        
        
        
    }
    
    //Envoit de la demande de pool suivante
    //if (isStop==0) {
        // si on à pas appuyer sur stop le pooling on continue la boucle
    
    
    double delayInSeconds = 60.0;
    if ([flgBackgroundAlertShow isEqual:@"false"]){
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void){
                       //your code here
                       [self performSelectorInBackground:@selector(longPoll) withObject: nil];
                   });
}
        //[self performSelectorInBackground:@selector(longPoll) withObject: nil];
    //}
}

- (void) startPoll {
    //Premier appel à long poll
    for(i=0; i<=10;i++)
    {
        [self performSelectorInBackground:@selector(longPoll) withObject: nil];
        if (i==10) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Call" message: @"online" delegate: self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            alert.tag = 1;
            [alert show];
        }
    }
}

- (void) dataReceived: (NSData*) theData {
    //process the response here
    
     NSLog(@" hghhgjjgj %@",theData);
    
    /*NSError* error = nil;
    NSString *jsonArry = [NSJSONSerialization
                          JSONObjectWithData:theData //1
                          
                          options:NSJSONReadingMutableContainers
                          error:&error];
    
    NSLog(@"jsonArryNew = %@",jsonArry);
    */
    
 NSString *strTheData = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    NSLog(@"newString = %@", strTheData);
    
    
    if ([strTheData isEqual:@"True"]) {
    }
    else if ([strTheData isEqual:@"False"]) {
    }
    else if ([strTheData isEqual:@"No Appointment"]) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Call" message: @"ggfgfh" delegate: self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        alert.tag = 1;
        [alert show];
        
         //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longPoll) object:nil];
        flgBackgroundAlertShow= @"true";*/
    }
    else
    {
        NSString* messageString = [NSString stringWithFormat: @"%@ is online", strTheData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Call" message: messageString delegate: self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        alert.tag = 1;
        [alert show];
        
        flgBackgroundAlertShow= @"true";
    }
}

//Pool



-(void) viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    CALayer *btnLayer = [_getAppointments layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)revelMenuPressed:(id)sender{
    [self.revealViewController revealToggle:sender];
    
   
}

-(IBAction)getAppointments:(id)sender{
    NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/GetAppointments?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    //NSString *_urlString = [NSString stringWithFormat:@"http://mobilevri.com/api/vri/GetAppointments?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    NSURL *url = [NSURL URLWithString:_urlString];
    
    //fetch current system date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/d/yyyy hh:mma"];//Wed, Dec 14 2011 1:50 PM
    NSString *str_date = [dateFormat stringFromDate:[NSDate date]];
    NSLog(@"str_date = %@",str_date);
    
    //determine three months from now
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:3];
    // Calculate when, according to Tom Lehrer, World War III will end
    NSDate *threeMonthsLater = [gregorian dateByAddingComponents:offsetComponents
                                                        toDate:[NSDate date] options:0];
    NSString *end_date = [dateFormat stringFromDate:threeMonthsLater];
    NSLog(@"str_date = %@",end_date);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:str_date forKey:@"fd"];
    [request setPostValue:end_date forKey:@"td"];
    [request start];
    NSError *error = [request error];
    if (!error) {
//        NSString *response = [request responseString];
//        NSLog(@"all appointments: %@", response);
        MVRIGlobalData *_jasonData = [MVRIGlobalData sharedInstance];
        if ([_jasonData parseData:[[request responseString] dataUsingEncoding:NSUTF8StringEncoding]]) {
            NSLog(@"number of child: %d" , [[_clientView subviews] count]);
            id _tableViewClass = [[_clientView subviews] objectAtIndex:0];
            if ([_tableViewClass isKindOfClass:[UITableView class]]) {
                UITableView *_apvc = (UITableView *) _tableViewClass;
                [_apvc reloadData];
            }
        }
       
    }
}

@end
