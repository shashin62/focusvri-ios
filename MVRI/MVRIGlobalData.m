//
//  MVRIGlobalData.m
//  MVRI
//
//  Created by mac on 11/18/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "MVRIGlobalData.h"

static MVRIGlobalData *_mvriGlobalDataInstance;

@implementation MVRIGlobalData
+(MVRIGlobalData*) sharedInstance{
    if (!_mvriGlobalDataInstance) {
        _mvriGlobalDataInstance = [[MVRIGlobalData alloc] init];
    }
    return _mvriGlobalDataInstance;
}

-(id) init{
    self = [super init];
    _clientList = [[NSMutableArray alloc] init];
    return self;
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
    
    NSArray* latestLoans = [json objectForKey:@"result"]; //2
    
//    NSLog(@"loans: %@", json); //3
//    NSLog(@"results : %@", latestLoans);
    NSLog(@"success : %@", [json objectForKey:@"success"]);
    if ([_clientList count] > 0) {
        [_clientList removeAllObjects];
    }
    for (NSDictionary *_tempDict in latestLoans) {
        [_clientList addObject:[[NSDictionary alloc] initWithDictionary:_tempDict copyItems:YES]];
    }
//    [_clientList addObjectsFromArray:latestLoans];
    
    return true;
}
@end
