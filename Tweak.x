#import <UIKit/UIKit.h>
#import <Security/Security.h>

%hook UnityAppController

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *tmpDir = NSTemporaryDirectory();

    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:docsDir error:nil];
    [fm removeItemAtPath:libDir error:nil];
    [fm removeItemAtPath:tmpDir error:nil];

    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: @"com.miniclip.8ballpoolmult"
    };
    SecItemDelete((__bridge CFDictionaryRef)query);

    %orig;
}

%end
