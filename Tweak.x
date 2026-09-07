#import <UIKit/UIKit.h>

void clearAppStoreData() {
    // 1. مسح جميع إعدادات NSUserDefaults
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // 2. مسح ملفات Caches و Documents و tmp
    NSArray *paths = @[
        [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject],
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],
        NSTemporaryDirectory()
    ];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *path in paths) {
        NSError *error = nil;
        NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
        for (NSString *file in files) {
            NSString *fullPath = [path stringByAppendingPathComponent:file];
            [fileManager removeItemAtPath:fullPath error:nil];
        }
    }
}

// ينفذ المسح فور تحميل التويك داخل الذاكرة عند فتح التطبيق
__attribute__((constructor)) static void initialize() {
    clearAppStoreData();
}

// Hook لضمان المسح أيضاً فور تحويل التطبيق للخلفية
%hook UIWindowScene
- (void)_willResignActive {
    %orig;
    clearAppStoreData();
}
%end
