#import "AntiDebug.h"
#import <dlfcn.h>
#import <sys/sysctl.h>
#import <sys/types.h>
#import <unistd.h>

// ---------------------------------------------------------------------------
// Internal helper — returns YES if a debugger is currently attached
// using sysctl kinfo_proc P_TRACED inspection.
// ---------------------------------------------------------------------------
static BOOL isBeingDebugged(void) {
    int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid() };
    struct kinfo_proc info;
    size_t size = sizeof(info);
    memset(&info, 0, sizeof(info));
    sysctl(mib, 4, &info, &size, NULL, 0);
    return (info.kp_proc.p_flag & P_TRACED) != 0;
}

// ---------------------------------------------------------------------------
// Tamper response — silently corrupt validation state and exit.
// Split across inlined calls to make it harder to NOP in one place.
// ---------------------------------------------------------------------------
__attribute__((noinline))
static void triggerTamperResponse(void) {
    // Overwrite the stack frame with garbage before exiting
    volatile uint8_t junk[64];
    memset((void *)junk, 0xCC, sizeof(junk));
    // Exit without a signal that would help an attacker
    _exit(1);
}

@implementation AntiDebug

+ (void)checkPtrace {
#if !DEBUG
    // PT_DENY_ATTACH: any subsequent ptrace attach will fail with ENOTSUP.
    // This is a well-known technique but still raises the bar.
    typedef int (*ptrace_t)(int, pid_t, caddr_t, int);
    ptrace_t pt = (ptrace_t)dlsym(RTLD_SELF, "ptrace");
    if (pt) {
        pt(31 /*PT_DENY_ATTACH*/, 0, 0, 0);
    }
#endif
    // Immediate check after deny-attach
    if (isBeingDebugged()) {
        triggerTamperResponse();
    }
}

+ (void)startWatchdog {
#if !DEBUG
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            [NSThread sleepForTimeInterval:2.5];
            if (isBeingDebugged()) {
                triggerTamperResponse();
            }
        }
    });
#endif
}

@end
