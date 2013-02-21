//
//  VMAppDelegate.m
//  VoiceMessage
//
//  Created by satoshi on 2012/12/02.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "VMAppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "BitlyConfig.h"

@implementation VMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if 0
    // Dump system sound list. begin_record.caf, end_record.caf
    NSError *error;
    NSString *path = @"/System/Library/Audio/UISounds";
    NSArray *sounds = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    for (NSString *file in sounds) {
        NSLog(@"Sound file:%@",file);
    }
#endif
    
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"userDefaults" ofType:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:plist];
    
    DBSession* dbSession = [[DBSession alloc] initWithAppKey:DROPBOX_APP_KEY
                                                   appSecret:DROPBOX_APP_SECRET
                                                        root:kDBRootDropbox];
    [DBSession setSharedSession:dbSession];

    [[BitlyConfig sharedBitlyConfig] setBitlyLogin:@"fsap" bitlyAPIKey:@"R_420b054d652ce5deb76632459b837192"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    VMLog(@"in. application[%@] url[%@] source[%@] annotation[%@]", application, url, sourceApplication, annotation);

    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
