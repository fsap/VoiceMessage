//
//  UTility.m
//  VoiceMessage
//
//  Created by satoshi on 2012/12/02.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "UTility.h"

@implementation UTility

+ (NSURL*) applicationDocumentURL{
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSURL *url = [NSURL URLWithString:path];
    return url;
}

+ (NSURL *)applicationHiddenDocumentsDirectory {
    // NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@".data"];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [libraryPath stringByAppendingPathComponent:@"Private Documents"];
    
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (isDirectory){
            NSURL *url = [NSURL fileURLWithPath:path];
            return url;
        }
        else {
            NSError *error = nil;
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
                [NSException raise:@"could not remove file" format:@"Path: %@", path];
            }
        }
    }
    else{
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            // Handle error.
            [NSException raise:@"Failed creating directory" format:@"[%@], %@", path, error];
        }
    }
    return [NSURL fileURLWithPath:path];
}

+ (NSString*) settingBundlePath{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"];
}
@end
