//
//  MVRIoovooMainviewController.h
//  MVRI
//
//  Created by mac on 11/10/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVRIoovooMainviewController : UITableViewController
@property (nonatomic, copy) NSString *applicationToken;
@property (nonatomic, copy) NSString *applicationId;
@property (nonatomic, copy) NSString *conferenceId;
@property (nonatomic, copy) NSString *opaqueString;

- (IBAction)joinConference:(id)sender;


@end
