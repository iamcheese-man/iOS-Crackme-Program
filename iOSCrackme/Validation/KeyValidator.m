#import "KeyValidator.h"
#import <CommonCrypto/CommonDigest.h>

// ---------------------------------------------------------------------------
// Obfuscated target blob (XOR-encoded expected transform of the key internals)
// Key answer: "CM-7F3A-X9Z2-K4Q8"  (don't put this in plaintext anywhere else)
//
// How it's derived:
//   inner = chars at indices 3..14 of the key = "7F3A-X9Z2-K4Q"
//   for each char c at position i: blob[i] = (uint8_t)(c ^ (0xAB + i))
// ---------------------------------------------------------------------------
static const uint8_t kTargetBlob[] = {
    0xDC, 0xBD, 0x98, 0xEF, 0xF0, 0xA1, 0xC2, 0xE3, 0xB4, 0xDB, 0xFC, 0x9D, 0xCE
};
static const NSUInteger kBlobLen = 13;

// ---------------------------------------------------------------------------
// Rolling hash constant
// ---------------------------------------------------------------------------
static uint32_t rollingHash(NSString *s) {
    uint32_t h = 0x811C9DC5u; // FNV-1a seed
    for (NSUInteger i = 0; i < s.length; i++) {
        uint8_t c = (uint8_t)[s characterAtIndex:i];
        h ^= c;
        h *= 0x01000193u;
        // Mix in position
        h ^= (uint32_t)(i * 0x9E3779B9u);
    }
    return h;
}

@implementation KeyValidator

+ (BOOL)validate:(NSString *)key {
    if (![self stage1_length:key])         return NO;
    if (![self stage2_structure:key])      return NO;
    if (![self stage3_checksum:key])       return NO;
    if (![self stage4_xorBlob:key])        return NO;
    if (![self stage5_rollingHash:key])    return NO;
    return YES;
}

// ---------------------------------------------------------------------------
// Stage 1 — Length must be exactly 18 characters
// ---------------------------------------------------------------------------
+ (BOOL)stage1_length:(NSString *)key {
    return key.length == 18;
}

// ---------------------------------------------------------------------------
// Stage 2 — Structural pattern: CM-XXXX-XXXX-XXXX
//           Prefix "CM-", dashes at indices 6 and 11
// ---------------------------------------------------------------------------
+ (BOOL)stage2_structure:(NSString *)key {
    if (![[key substringToIndex:3] isEqualToString:@"CM-"]) return NO;
    if ([key characterAtIndex:6]  != '-') return NO;
    if ([key characterAtIndex:11] != '-') return NO;

    // Remaining chars (non-dash, non-prefix) must be alphanumeric uppercase or digit
    NSCharacterSet *allowed = [NSCharacterSet alphanumericCharacterSet];
    NSArray<NSNumber *> *skipIdx = @[@0, @1, @2, @6, @11];
    for (NSUInteger i = 3; i < key.length; i++) {
        BOOL skip = NO;
        for (NSNumber *idx in skipIdx) if (idx.unsignedIntegerValue == i) { skip = YES; break; }
        if (skip) continue;
        unichar c = [key characterAtIndex:i];
        if (![allowed characterIsMember:c]) return NO;
    }
    return YES;
}

// ---------------------------------------------------------------------------
// Stage 3 — Checksum: sum of ASCII values of chars at even indices == 0x2F6
// ---------------------------------------------------------------------------
+ (BOOL)stage3_checksum:(NSString *)key {
    NSUInteger sum = 0;
    for (NSUInteger i = 0; i < key.length; i += 2) {
        sum += (uint8_t)[key characterAtIndex:i];
    }
    return (sum == 0x2F6); // 758 decimal
}

// ---------------------------------------------------------------------------
// Stage 4 — XOR blob: inner 13 chars (indices 3..15) XORed with (0xAB + i)
//           must match kTargetBlob
// ---------------------------------------------------------------------------
+ (BOOL)stage4_xorBlob:(NSString *)key {
    for (NSUInteger i = 0; i < kBlobLen; i++) {
        uint8_t c   = (uint8_t)[key characterAtIndex:i + 3];
        uint8_t enc = (uint8_t)(c ^ (0xAB + i));
        if (enc != kTargetBlob[i]) return NO;
    }
    return YES;
}

// ---------------------------------------------------------------------------
// Stage 5 — Rolling hash of the full key must equal 0x4E2A1CF7
// ---------------------------------------------------------------------------
+ (BOOL)stage5_rollingHash:(NSString *)key {
    uint32_t h = rollingHash(key);
    return (h == 0x4E2A1CF7u);
}

@end
