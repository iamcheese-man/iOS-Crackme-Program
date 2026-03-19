#import "AppDelegate.h"
#import "AntiDebug.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Anti-debug check at launch
    [AntiDebug startWatchdog];
    return YES;
}

@end
