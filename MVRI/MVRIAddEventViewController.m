//
//  MVRIAddEventViewController.m
//  MVRI
//
//  Created by Addya on 03/05/14.
//  Copyright (c) 2014 mac. All rights reserved.
//

#import "MVRIAddEventViewController.h"
#import "ASIFormDataRequest.h"

@interface MVRIAddEventViewController ()

@end


UIDatePicker *theDatePicker;
UIDatePicker *theEndDatePicker;
//UIToolbar* pickerToolbar;
//UIActionSheet* pickerViewDate;
NSNumber *Clientid, *InterpreterId, *LangId, *CatId;


@implementation MVRIAddEventViewController

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
    
    [scrollView1 setScrollEnabled:YES];
    [scrollView1 setContentSize:CGSizeMake(320, 830)];
    
    //txtClaim.returnKeyType = UIReturnKeyDone;
    [txtClaim setDelegate:self];
    
    //For Client Picker
    NSArray *jsonArry;
    NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/_GetPersonnel?key=%@&type=client", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
   
    [request setRequestMethod:@"Post"];
    [request start];
    
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"buffer time: %@", response);
        
        NSData *responseData=[response dataUsingEncoding:NSUTF8StringEncoding];
        
        jsonArry = [NSJSONSerialization
                             JSONObjectWithData:responseData //1
                             
                             options:NSJSONReadingMutableContainers
                             error:&error];
        
        NSLog(@"data%@",jsonArry);
    }
    
    //pickItems= [NSArray    arrayWithObjects:@"NewYork",@"NewJercy",@"Carlifornia",@"Florida",@"Fremont",@"SantaClara",@"San Diego",@"San Fransisco",@"San Jose", nil];
    
    pickItems=[ jsonArry valueForKey:@"value"];
    _pickItemsId = [ jsonArry valueForKey:@"id"];
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    pickerView  .delegate = self;
    pickerView  .dataSource = self;
    [ pickerView  setShowsSelectionIndicator:YES];
    pickerView.tag=1;
    [pickerView reloadAllComponents];
    
    txtClientName.inputView =  pickerView  ;
    
    // Create done button in UIPickerView
    
    
    UIToolbar*  mypickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    mypickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [mypickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked)];
    [barItems addObject:doneBtn];
    
    [mypickerToolbar setItems:barItems animated:YES];
    
    txtClientName.inputAccessoryView = mypickerToolbar;
    //For Client Picker
    
    
    //For Interpreter Picker
    NSArray *jsonArry2;
    NSString *_urlString2 = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/_GetPersonnel?key=%@&type=interpreter", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    
    NSURL *url2 = [NSURL URLWithString:_urlString2];
    ASIFormDataRequest *request2 = [ASIFormDataRequest requestWithURL:url2];
    
    [request2 setRequestMethod:@"Post"];
    [request2 start];
    
    NSError *error2 = [request2 error];
    if (!error2) {
        NSString *response2 = [request2 responseString];
        NSLog(@"buffer time: %@", response2);
        
        NSData *responseData2 =[response2 dataUsingEncoding:NSUTF8StringEncoding];
        
        jsonArry2 = [NSJSONSerialization
                    JSONObjectWithData:responseData2 //1
                    
                    options:NSJSONReadingMutableContainers
                    error:&error2];
        
        NSLog(@"data%@",jsonArry2);
    }
    
    //pickItems= [NSArray    arrayWithObjects:@"NewYork",@"NewJercy",@"Carlifornia",@"Florida",@"Fremont",@"SantaClara",@"San Diego",@"San Fransisco",@"San Jose", nil];
    
    pickItemsInterpreter=[ jsonArry2 valueForKey:@"value"];
    _pickItemsIdInterpreter = [ jsonArry2 valueForKey:@"id"];
    
    pickerViewInterpreter = [[UIPickerView alloc] initWithFrame:CGRectZero];
    pickerViewInterpreter  .delegate = self;
    pickerViewInterpreter  .dataSource = self;
    [ pickerViewInterpreter  setShowsSelectionIndicator:YES];
    pickerViewInterpreter.tag=2;
    [pickerViewInterpreter reloadAllComponents];
    
    txtInterpreterName.inputView =  pickerViewInterpreter  ;
    
    txtInterpreterName.inputAccessoryView = mypickerToolbar;
    //For Interpreter  Picker
    
    
    //For start Dt
    
    theDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
    theDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    [theDatePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    
    txtStartDt.inputView =  theDatePicker  ;
    
    txtStartDt.inputAccessoryView = mypickerToolbar;
    //For start Dt
    
    
    //For end Dt
    
    theEndDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
    theEndDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter2 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter2 setDateFormat:@"dd MMM yyyy"];
    [theEndDatePicker addTarget:self action:@selector(enddateChanged) forControlEvents:UIControlEventValueChanged];
    
    txtEndDt.inputView =  theEndDatePicker  ;
    
    txtEndDt.inputAccessoryView = mypickerToolbar;
    //For end Dt
    
    
    //For Language Picker
    NSArray *jsonArryLang;
    NSString *_urlStringLang = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/GetLanguages?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    
    NSURL *urlLang = [NSURL URLWithString:_urlStringLang];
    ASIFormDataRequest *requestLang = [ASIFormDataRequest requestWithURL:urlLang];
    
    [requestLang setRequestMethod:@"Get"];
    [requestLang start];
    
    NSError *errorLang = [requestLang error];
    if (!errorLang) {
        NSString *responseLang = [requestLang responseString];
        NSLog(@"buffer time: %@", responseLang);
        
        NSData *responseDataLang =[responseLang dataUsingEncoding:NSUTF8StringEncoding];
        
        jsonArryLang = [NSJSONSerialization
                     JSONObjectWithData:responseDataLang //1
                     
                     options:NSJSONReadingMutableContainers
                     error:&errorLang];
        
        NSLog(@"data%@",jsonArryLang);
    }
    
    //pickItems= [NSArray    arrayWithObjects:@"NewYork",@"NewJercy",@"Carlifornia",@"Florida",@"Fremont",@"SantaClara",@"San Diego",@"San Fransisco",@"San Jose", nil];
    
    pickItemsLanguage=[ jsonArryLang valueForKey:@"Language"];
    _pickItemsIdLanguage = [ jsonArryLang valueForKey:@"Id"];
    
    pickerViewLanguage = [[UIPickerView alloc] initWithFrame:CGRectZero];
    pickerViewLanguage  .delegate = self;
    pickerViewLanguage  .dataSource = self;
    [ pickerViewLanguage  setShowsSelectionIndicator:YES];
    pickerViewLanguage.tag=5;
    [pickerViewLanguage reloadAllComponents];
    
    txtLanguage.inputView =  pickerViewLanguage  ;
    
    txtLanguage.inputAccessoryView = mypickerToolbar;
    //For Language  Picker
    
    
    
    //For Category Picker
    NSArray *jsonArryCategory;
    NSString *_urlStringCategory = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/GetCategory?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    
    NSURL *urlCategory = [NSURL URLWithString:_urlStringCategory];
    ASIFormDataRequest *requestCategory = [ASIFormDataRequest requestWithURL:urlCategory];
    
    [requestCategory setRequestMethod:@"Get"];
    [requestCategory start];
    
    NSError *errorCategory = [requestCategory error];
    if (!errorCategory) {
        NSString *responseCategory = [requestCategory responseString];
        NSLog(@"buffer time: %@", responseCategory);
        
        NSData *responseDataLang =[responseCategory dataUsingEncoding:NSUTF8StringEncoding];
        
        jsonArryCategory = [NSJSONSerialization
                        JSONObjectWithData:responseDataLang //1
                        
                        options:NSJSONReadingMutableContainers
                        error:&errorCategory];
        
        NSLog(@"data%@",jsonArryCategory);
    }
    
    //pickItems= [NSArray    arrayWithObjects:@"NewYork",@"NewJercy",@"Carlifornia",@"Florida",@"Fremont",@"SantaClara",@"San Diego",@"San Fransisco",@"San Jose", nil];
    
    pickItemsCategory=[ jsonArryCategory valueForKey:@"value"];
    _pickItemsIdCategory = [ jsonArryCategory valueForKey:@"id"];
    
    pickerViewCategory = [[UIPickerView alloc] initWithFrame:CGRectZero];
    pickerViewCategory  .delegate = self;
    pickerViewCategory  .dataSource = self;
    [ pickerViewCategory  setShowsSelectionIndicator:YES];
    pickerViewCategory.tag=6;
    [pickerViewCategory reloadAllComponents];
    
    txtCategory.inputView =  pickerViewCategory  ;
    
    txtCategory.inputAccessoryView = mypickerToolbar;
    //For Language  Picker
    
}

-(void)pickerDoneClicked
{
  	//NSLog(@"Done Clicked");
    [txtClientName resignFirstResponder];
    [txtInterpreterName resignFirstResponder];
    [txtStartDt resignFirstResponder];
    [txtEndDt resignFirstResponder];
    [txtLanguage resignFirstResponder];
    [txtCategory resignFirstResponder];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView tag] == 1) {
        return pickItems.count;
    }
    else if([pickerView tag] == 2)
    {
        return pickItemsInterpreter.count;
    }
    else if([pickerView tag] == 3)
    {
        return 30;
    }
    else if([pickerView tag] == 4)
    {
        return 30;
    }
    else if([pickerView tag] == 5)
    {
        return pickItemsLanguage.count;
    }
    else if([pickerView tag] == 6)
    {
        return pickItemsCategory.count;
    }
    //return pickItems.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView tag] == 1) {
        return [pickItems objectAtIndex:row];
    }
    else if([pickerView tag] == 2)
    {
        return [pickItemsInterpreter objectAtIndex:row];
    }
    else if([pickerView tag] == 3)
    {
        //return 30;
    }
    else if([pickerView tag] == 4)
    {
        //return 30;
    }
    else if([pickerView tag] == 5)
    {
        return [pickItemsLanguage objectAtIndex:row];
    }
    else if([pickerView tag] == 6)
    {
        return [pickItemsCategory objectAtIndex:row];
    }
    //return [pickItems objectAtIndex:row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView tag] == 1)
    {
        txtClientName.text = (NSString *)[pickItems objectAtIndex:row];
        Clientid = [_pickItemsId objectAtIndex:row];
    }
    else if([pickerView tag] == 2)
    {
        txtInterpreterName.text = (NSString *)[pickItemsInterpreter objectAtIndex:row];
        InterpreterId = [_pickItemsIdInterpreter objectAtIndex:row];
    }
    else if([pickerView tag] == 3)
    {
        
    }
    else if([pickerView tag] == 4)
    {
        
    }
    else if([pickerView tag] == 5)
    {
        txtLanguage.text = (NSString *)[pickItemsLanguage objectAtIndex:row];
        LangId = [_pickItemsIdLanguage objectAtIndex:row];
    }
    else if([pickerView tag] == 6)
    {
        txtCategory.text = (NSString *)[pickItemsCategory objectAtIndex:row];
        CatId = [_pickItemsIdCategory objectAtIndex:row];
    }
}



-(void)DatePickerView
{
    /*pickerViewDate = [[UIActionSheet alloc] initWithTitle:@"How many?"
                                                 delegate:self
                                        cancelButtonTitle:nil
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:nil];
    
    theDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
    theDatePicker.datePickerMode = UIDatePickerModeDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];*/
    //[dateFormatter setDateFormat:@"MM/dd/YYYY"];
    
    //[theDatePicker release];
    /*[theDatePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    theDatePicker.tag=3;
    
    pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pickerToolbar.barStyle=UIBarStyleBlackOpaque;
    [pickerToolbar sizeToFit];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DatePickerDoneClick)];
    [barItems addObject:flexSpace];
    
    [pickerToolbar setItems:barItems animated:YES];
    [pickerViewDate addSubview:pickerToolbar];
    [pickerViewDate addSubview:theDatePicker];
    [pickerViewDate  showInView:self.view];
    [pickerViewDate setBounds:CGRectMake(0,0,320, 464)];*/
}

-(IBAction)dateChanged{
    
    NSDateFormatter *FormatDate = [[NSDateFormatter alloc] init];
    [FormatDate setLocale: [[NSLocale alloc]
                             initWithLocaleIdentifier:@"en_US"]];
    [FormatDate setDateFormat:@"MM/dd/YYYY hh:mm:ss aa"];
    //[FormatDate setDateStyle:NSDateFormatterShortStyle];
    //[FormatDate setTimeStyle:NSDateFormatterShortStyle];
    txtStartDt.text = [FormatDate stringFromDate:[theDatePicker date]];
}


-(BOOL)closeDatePicker:(id)sender{
    //[pickerViewDate dismissWithClickedButtonIndex:0 animated:YES];
    [txtStartDt resignFirstResponder];
    
    return YES;
}


-(IBAction)enddateChanged{
    
    NSDateFormatter *FormatDate = [[NSDateFormatter alloc] init];
    [FormatDate setLocale: [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"]];
    [FormatDate setDateFormat:@"MM/dd/YYYY hh:mm:ss aa"];
    //[FormatDate setDateStyle:NSDateFormatterShortStyle];
    //[FormatDate setTimeStyle:NSDateFormatterShortStyle];
    txtEndDt.text = [FormatDate stringFromDate:[theEndDatePicker date]];
    
    
    NSDate *startdt=txtStartDt.text;
    NSDate *enddt=txtEndDt.text;
   // NSTimeInterval distanceBetweenDates = [enddt timeIntervalSinceDate:startdt];
    //double secondsInMinute = 60;
    //NSInteger secondsBetweenDates = distanceBetweenDates / secondsInMinute;
    /*if(enddt < startdt)
    //if (secondsBetweenDates < 0)
    {
        //NSString* messageString = [NSString stringWithFormat: @"%@ is online", strTheData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"End date should be less than Start date." delegate: self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        alert.tag = 1;
        [alert show];
    }*/
}

/*-(IBAction)DatePickerDoneClick{
    [self closeDatePicker:self];
    tableview.frame=CGRectMake(0, 44, 320, 416);
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 30;
    //    return [pickerViewArray count];
}
*/


- (IBAction)btnAppointSubmit:(UIButton *)sender
{
    NSLog(@"Button Tapped!");
    NSArray *jsonArry;
    NSString *_urlString = [NSString stringWithFormat:@"http://login.mobilevri.com/api/vri/QuickAppointment?key=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"MVRISessionID"]];
    
    NSURL *url = [NSURL URLWithString:_urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:InterpreterId forKey:@"interpreterid"];
    [request setPostValue:Clientid forKey:@"clientid"];
    [request setPostValue:txtStartDt.text forKey:@"startdate"];
    [request setPostValue:txtEndDt.text forKey:@"enddate"];
    /*[request setPostValue:str_date forKey:@"followupdate"];
    [request setPostValue:str_date forKey:@"followupreason"];
    [request setPostValue:str_date forKey:@"completed"];
    [request setPostValue:str_date forKey:@"disputed"];
    [request setPostValue:str_date forKey:@"amount"];
    [request setPostValue:str_date forKey:@"clientnote"];
    [request setPostValue:str_date forKey:@"interpreternote"];
    [request setPostValue:str_date forKey:@"conferenceid"];*/
    [request setPostValue:txtLanguage.text forKey:@"language"];
    [request setPostValue: CatId  forKey:@"ApptCatId"];
    [request setPostValue:txtClaim.text forKey:@"claimno"];
    
    
    [request setRequestMethod:@"Post"];
    [request start];
    
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"buffer time: %@", response);
        
        NSData *responseData=[response dataUsingEncoding:NSUTF8StringEncoding];
        
        jsonArry = [NSJSONSerialization
                    JSONObjectWithData:responseData //1
                    
                    options:NSJSONReadingMutableContainers
                    error:&error];
        
        NSLog(@"data%@",jsonArry);
        
        if([response  isEqual: @"Appointments already exists for either client or interpretor between specified dates. Please select free dates."])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Appointments already exists for either client or interpretor between specified dates. Please select free dates." delegate: self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            alert.tag = 1;
            [alert show];
        }
        else if([response  isEqual: @"Invalid appointment data"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Invalid appointment data." delegate: self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            alert.tag = 1;
            [alert show];
        }
        else if([response  isEqual: @"Invalid user"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Invalid user." delegate: self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            alert.tag = 1;
            [alert show];
        }
        else
        {
            [self performSegueWithIdentifier:@"segueFromEvent" sender:self];
        }
    }
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
