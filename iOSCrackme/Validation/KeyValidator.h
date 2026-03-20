#import <Foundation/Foundation.h>

/**
 * KeyValidator — Multi-stage key validation.
 *
 * Validation stages (reverse-engineer each to understand the expected key):
 *  Stage 1: Length check
 *  Stage 2: Prefix/suffix pattern
 *  Stage 3: Checksum of inner chars
 *  Stage 4: XOR-based transform comparison against a stored blob
 *  Stage 5: Rolling hash over char positions
 */
@interface KeyValidator : NSObject

/// Returns YES if the provided key passes all validation stages.
+ (BOOL)validate:(NSString *)key;

@end
