//
//  UTility.h
//  VoiceMessage
//
//  Created by satoshi on 2012/12/02.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UTility : NSObject
//+ (NSURL*) applicationDocumentURL;
+ (NSURL *)applicationHiddenDocumentsDirectory;
+ (NSString*) settingBundlePath;
@end
