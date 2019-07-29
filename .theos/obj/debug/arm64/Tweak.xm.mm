#line 1 "Tweak.xm"
















static short const kUDIDLength = 40;
static short const kPrefixLength = 25;
static short const kSuffixLength = 9;


static uint8_t const kPrefix[kPrefixLength] = {
  0x3C, 0x6B, 0x65, 0x79, 0x3E, 0x55, 0x44, 0x49,
  0x44, 0x3C, 0x2F, 0x6B, 0x65, 0x79, 0x3E, 0x0A,
  0x09, 0x3C, 0x73, 0x74, 0x72, 0x69, 0x6E, 0x67,
  0x3E
};


static uint8_t const kSuffix[kSuffixLength] = {
  0x3C, 0x2F, 0x73, 0x74, 0x72, 0x69, 0x6E, 0x67, 0x3E
};

static NSString * generateRandomString(NSInteger length) {
    
    NSMutableString *randomizedText = [NSMutableString stringWithString:@"df9249d4418qe1e79c87d1a58fe4247434eff1d1"];
    NSString *buffer = nil;
    for (NSInteger i = randomizedText.length - 1, j; i >= 0; i--) {
        j = arc4random() % (i + 1);
        buffer = [randomizedText substringWithRange:NSMakeRange(i, 1)];
        [randomizedText replaceCharactersInRange:NSMakeRange(i, 1) withString:[randomizedText substringWithRange:NSMakeRange(j, 1)]];
        [randomizedText replaceCharactersInRange:NSMakeRange(j, 1) withString:buffer];
    }
    return [randomizedText copy];
}

static NSData *replacedUUIDData(NSData *data) {
    NSUInteger minLength = kSuffixLength + kUDIDLength + kSuffixLength;
    if (data.length <= minLength) {
        return data;
    }

    uint8_t *buffer = (uint8_t *)[data bytes];
    uint32_t bufferSize = 0;
    uint8_t *bufferBegin = buffer;
    uint8_t *bufferEnd = buffer + data.length;
    while (bufferBegin != bufferEnd && bufferSize < data.length) {
        if (0 == memcmp(bufferBegin, kPrefix, kPrefixLength)) {
            if (0 == memcmp(bufferBegin + kPrefixLength + kUDIDLength, kSuffix, kSuffixLength)) {
                generateRandomString(40);
                NSString *fakeUDID = @"2497f8c8afded2354e447f8411d419q7e1f1e4d9";
                NSLog(@"Found UDID location, trying to replace it with %@", fakeUDID);
                strncpy((char *)bufferBegin + kPrefixLength, [fakeUDID UTF8String], kUDIDLength);
                break;
            }
        }
        ++bufferBegin;
        ++bufferSize;
    }
    
    return [NSData dataWithBytes:buffer length:data.length];
}


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class MCHTTPTransaction; 
static void (*_logos_orig$_ungrouped$MCHTTPTransaction$setData$)(_LOGOS_SELF_TYPE_NORMAL MCHTTPTransaction* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$MCHTTPTransaction$setData$(_LOGOS_SELF_TYPE_NORMAL MCHTTPTransaction* _LOGOS_SELF_CONST, SEL, id); 

#line 74 "Tweak.xm"


static void _logos_method$_ungrouped$MCHTTPTransaction$setData$(_LOGOS_SELF_TYPE_NORMAL MCHTTPTransaction* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {

    

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSLog(@"💖💖💖💖💖💖💖💖💖 %@",paths);
    NSString *docDir = [paths objectAtIndex:0];
    if(!docDir) {
        NSLog(@"Documents 目录未找到");
    }
    NSString *filePath = [docDir stringByAppendingPathComponent:@"testFile1.p7s"];
    [arg1 writeToFile:filePath atomically:YES];

    
    HBLogDebug(@"-[<MCHTTPTransaction: %p> setData:%@]", self, arg1);

    NSString *filePath2 = [docDir stringByAppendingPathComponent:@"testFile2.p7s"];
    [replacedUUIDData(arg1) writeToFile:filePath2 atomically:YES];

    _logos_orig$_ungrouped$MCHTTPTransaction$setData$(self, _cmd, replacedUUIDData(arg1));
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$MCHTTPTransaction = objc_getClass("MCHTTPTransaction"); MSHookMessageEx(_logos_class$_ungrouped$MCHTTPTransaction, @selector(setData:), (IMP)&_logos_method$_ungrouped$MCHTTPTransaction$setData$, (IMP*)&_logos_orig$_ungrouped$MCHTTPTransaction$setData$);} }
#line 99 "Tweak.xm"
