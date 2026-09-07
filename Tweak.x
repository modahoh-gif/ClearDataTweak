#import <UIKit/UIKit.h>
#import <Security/Security.h>

// دالة مسح الـ Keychain المسؤولة عن حفظ مفاتيح التفعيل وتوكين الوقت
void resetModKeychain() {
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

// دالة المسح الشاملة للملفات والإعدادات
void purgeAllModData() {
    // 1. مسح الـ UserDefaults
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // 2. مسح الـ Keychain
    resetModKeychain();

    // 3. مسح جميع أدلة البيانات المحلية (Documents, Caches, App Support, tmp)
    NSString *homeDir = NSHomeDirectory();
    NSArray *directories = @[
        [homeDir stringByAppendingPathComponent:@"Documents"],
        [homeDir stringByAppendingPathComponent:@"Library/Caches"],
        [homeDir stringByAppendingPathComponent:@"Library/Application Support"],
        [homeDir stringByAppendingPathComponent:@"Library/Preferences"],
        [homeDir stringByAppendingPathComponent:@"tmp"]
    ];

    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSString *dir in directories) {
        NSArray *files = [fm contentsOfDirectoryAtPath:dir error:nil];
        for (NSString *file in files) {
            // تجنب حذف مجلد Preferences نفسه لتفادي انهيار النظام المباشر
            if ([file isEqualToString:@"Preferences"]) continue;
            
            NSString *filePath = [dir stringByAppendingPathComponent:file];
            [fm removeItemAtPath:filePath error:nil];
        }
    }
}

// Hook على مستوى دورة حياة التطبيق عند الخروج أو الانتقال للخلفية
%hook UIApplication

- (void)applicationDidEnterBackground:(UIApplication *)application {
    %orig;
    purgeAllModData();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    %orig;
    purgeAllModData();
}

%end

// Hook حديث لدعم نظام iOS 13+ (SceneDelegate) عند إنزال اللعبة للخلفية
%hook UIWindowScene

- (void)_willResignActive {
    %orig;
    purgeAllModData();
}

%end
