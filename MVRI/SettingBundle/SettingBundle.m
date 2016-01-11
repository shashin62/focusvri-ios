
#import "SettingBundle.h"
#import <ooVooSDK/ooVooSDK.h>

//#define TOKEN "MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB3%2FzccoF9OWJIKIBCUVQTYAtMKTiDLjGTGnr4GChLXCbYmEJ%2FXZZCCVXLlQ9KIQaIeQ71rJUlXgMytjc7kLQb%2Fxk5nEw%2BUT5ZPBzF0r%2B%2FDXSnCVy3eZgFFUx0%2BpgZJ%2BHpQpgQ34MAI%2FeHvJ0jVA6Qz"

#define TOKEN "MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD6dksiFYCuO5gnzelHYQMSctCH4GXen%2F44tKL5hlSY26oZLjvYYtJjNYInR73kvcUZ6YADfXSig8xLTmzC06%2FW0G%2B62GKr8xttn%2BkgzuU%2BXm0kXov8qGUdFmTtmhBhBQ%2F%2FeSN1HkVndI8vMwnshrVG"

@implementation SettingBundle {
    NSUserDefaults *def;
}

static SettingBundle *settings = nil;

+ (SettingBundle *)sharedSetting {
    if (settings == nil) {
        settings = [[SettingBundle alloc] init];
        [self regDefaults];
    }
    return settings;
}

- (NSString *)getSettingForKey:(NSString *)key {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    return [defaults objectForKey:key];
}

- (void)setSettingKey:(NSString *)key WithValue:(NSString *)value {

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    [def setObject:value forKey:key];

    [def synchronize];
}

+ (void)regDefaults {

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    NSDictionary *dicAppToken = [NSDictionary dictionaryWithObject:@TOKEN forKey:@"settingBundle_AppToken"];
    NSDictionary *dicAppLogLevl = [NSDictionary dictionaryWithObject:@6 forKey:@"settingBundle_SDK_LogLevel"];
    NSString *appVersion =  [ooVooClient getSdkVersion];
    NSDictionary *dicAppVersion = [NSDictionary dictionaryWithObject:appVersion forKey:@"settingBundle_SDK_Version"];

    [def registerDefaults:dicAppToken];
    [def registerDefaults:dicAppVersion];
    [def registerDefaults:dicAppLogLevl];
    
    [def synchronize];
};

@end
