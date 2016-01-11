//
//  ActiveUserManager.h

#import <Foundation/Foundation.h>

@interface ActiveUserManager : NSObject

@property (nonatomic, strong) NSString *userId;
+ (ActiveUserManager *)activeUser;

@end
