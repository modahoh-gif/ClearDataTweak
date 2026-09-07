#import <UIKit/UIKit.h>
#import <Security/Security.h>

// 1. مسح جميع بيانات الـ Keychain الخاصة بالتطبيق
void resetKeychain() {
    NSArray *secClasses = @[
        (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecClassInternetPassword,
        (__bridge id)kSecClassCertificate,
        (__bridge id)kSecClassKey,
        (__bridge id)kSecClassIdentity
    ];
    
    for (id secClass in secClasses) {
        NSDictionary *spec = @{(__bridge id)kSecClass: secClass};
        SecItemDelete((__bridge CFDictionaryRef)spec);
    }
}

// 2. مسح شجرة مجلدات الـ Sandbox بالكامل
void wipeSandboxData() {
    // مسح الـ UserDefaults بالكامل
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // تحديد كافة المسارات الهامة داخل حاوية التطبيق
    NSString *homeDir = NSHomeDirectory();
    NSArray *directoriesToWipe = @[
        [homeDir stringByAppendingPathComponent:@"Documents"],
        [homeDir stringByAppendingPathComponent:@"Library/Caches"],
        [homeDir stringByAppendingPathComponent:@"Library/Application Support"],
        [homeDir stringByAppendingPathComponent:@"Library/Preferences"],
        [homeDir stringByAppendingPathComponent:@"tmp"]
    ];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSString *dirPath in directoriesToWipe) {
        NSError *error = nil;
        NSArray *files = [fileManager contentsOfDirectoryAtPath:dirPath error:&error];
        for (NSString *file in files) {
            // تخطي ملفات النظام الأساسية التي قد تسبب انهياراً فورياً
            if ([file isEqualToString:@"Preferences"]) continue; 
            
            NSString *fullPath = [dirPath stringByAppendingPathComponent:file];
            [fileManager removeItemAtPath:fullPath error:nil];
        }
    }
}

// تنفيذ المسح الشامل فور تحميل التويك بالذاكرة
__attribute__((constructor)) static void fullResetOnLaunch() {
    resetKeychain();
    wipeSandboxData();
}

// مسح إضافي عند إنزال التطبيق للخلفية
%hook UIWindowScene
- (void)_willResignActive {
    %orig;
    resetKeychain();
    wipeSandboxData();
}
%end
