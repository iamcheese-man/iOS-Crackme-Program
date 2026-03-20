#import <Foundation/Foundation.h>

/**
 * AntiDebug — Techniques to detect and respond to debugger attachment.
 *
 * Techniques used:
 *  1. sysctl PT_DENY_ATTACH  (ptrace)
 *  2. sysctl kinfo_proc P_TRACED flag check
 *  3. Periodic watchdog timer re-checking the traced flag
 *
 * When a debugger is detected the app intentionally corrupts its own state
 * and exits — it does NOT crash noisily so the attacker gets less info.
 */
@interface AntiDebug : NSObject

/// Call once at AppDelegate launch. Blocks attachment via ptrace.
+ (void)checkPtrace;

/// Starts a background NSTimer that periodically re-checks for a debugger.
+ (void)startWatchdog;

@end
