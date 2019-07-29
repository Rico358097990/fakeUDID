/*
实现流程: 
经过研究, MCHTTPTransaction 类中的 `data` 字段就是发送给 UDID 请求网站的回调服务器的数据, 包含 UDID 等数据，它使用 PKCS#7 签名.
这个字段使用 NSString 是无法正确解码它的, 所以用 Obj-C 字符串的方式没办法编辑它.
我最初尝试直接返回未签名的 xml, 在类似于 fir.im 这种没有做签名校验的网站是可以通过的, 但是在 udid.io 这种做了签名校验的网站通不过,
所以我尝试找它的签名函数, 也确实成功拿到了, 但是没有找到计算和签名这个 `data` 字段的函数, 故而条路放弃.
我尝试在 udid.io 被回调之前在 Charles 中修改掉 udid 的值, 该网站依然返回正确响应, 这可以证明 xml 内容和签名是无关的.
那么这样一来最简单的方式就是直接修改 hex, 因为无法解码, 所以 NSString 之类的类是不能编辑它的.

响应体中 xml 里 UDID 元素的样式如下: 
<key>UDID</key>\n\t<string>4194e4e27qdf84df725d487431fce8e11fd991</string>

那么我们可以先找到 `<key>UDID</key>\n\t<string>` 的位置, 然后向后偏移 40(UDID 的长度) 再检查是不是 `</string>`,
如果符合这种情况, 就把中间的 udid 替换掉.
*/

static short const kUDIDLength = 40;
static short const kPrefixLength = 25;
static short const kSuffixLength = 9;

/// <key>UDID</key>\n\t<string>
static uint8_t const kPrefix[kPrefixLength] = {
  0x3C, 0x6B, 0x65, 0x79, 0x3E, 0x55, 0x44, 0x49,
  0x44, 0x3C, 0x2F, 0x6B, 0x65, 0x79, 0x3E, 0x0A,
  0x09, 0x3C, 0x73, 0x74, 0x72, 0x69, 0x6E, 0x67,
  0x3E
};

/// </string>
static uint8_t const kSuffix[kSuffixLength] = {
  0x3C, 0x2F, 0x73, 0x74, 0x72, 0x69, 0x6E, 0x67, 0x3E
};

static NSString * generateRandomString(NSInteger length) {
    /// 总长度 40, 其中 25 位数字, 其他是字母. (其实网站并不会验证这个规则...)
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

%hook MCHTTPTransaction

- (void)setData:(id)arg1 {

    

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSLog(@"💖💖💖💖💖💖💖💖💖 %@",paths);
    NSString *docDir = [paths objectAtIndex:0];
    if(!docDir) {
        NSLog(@"Documents 目录未找到");
    }
    NSString *filePath = [docDir stringByAppendingPathComponent:@"testFile1.p7s"];
    [arg1 writeToFile:filePath atomically:YES];

    
    %log;

    NSString *filePath2 = [docDir stringByAppendingPathComponent:@"testFile2.p7s"];
    [replacedUUIDData(arg1) writeToFile:filePath2 atomically:YES];

    %orig(replacedUUIDData(arg1));
}

%end