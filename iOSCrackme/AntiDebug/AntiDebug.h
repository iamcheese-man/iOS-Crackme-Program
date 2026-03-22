#import <Foundation/Foundation.h>

@interface AntiDebug : NSObject

+ (void)checkPtrace;

+ (void)startWatchdog;

@end
