//
//  MVRIGlobalData.h
//  MVRI
//
//  Created by mac on 11/18/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVRIGlobalData : NSObject
@property (atomic, strong) NSMutableArray *clientList;
@property (atomic, strong) NSString *username;
@property (atomic, strong) NSString *Firstname;
@property (atomic, strong) NSString *UsrRole;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *genderType;
@property (nonatomic, strong) NSString *conferenceID;
@property (nonatomic, strong) NSString *getInterPreterIDWhenClaimantcalled;
@property (nonatomic, strong) NSDate *callStartDate;
@property (nonatomic, strong) NSDictionary *languageDictionary;
@property (nonatomic, strong) NSDictionary *skillDictionary;

+(MVRIGlobalData*) sharedInstance;

-(BOOL) parseData:(NSData*)responseData;
@end
