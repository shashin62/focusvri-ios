//
//  MVRICalenderViewController.h
//  MVRI
//
//  Created by mac on 11/26/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import <TapkuLibrary/TapkuLibrary.h>
#import <UIKit/UIKit.h>


@interface MVRICalenderViewController : TKCalendarMonthTableViewController

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableDictionary *dataDictionary;
@property (nonatomic,strong) NSArray *allResults;


- (void) generateRandomDataForStartDate:(NSDate*)start endDate:(NSDate*)end;
- (void) generateDataForStartDate:(NSDate*)start endDate:(NSDate*)end;

@end
