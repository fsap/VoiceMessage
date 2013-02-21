//
//  VMMainViewController.h
//  VoiceMessage
//
//  Created by satoshi on 2012/12/02.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "VMInputSubjectViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface VMConnectDropBoxViewController : UIViewController <VMInputSubjectViewControllerDelegate,DBRestClientDelegate>

@property (strong,nonatomic) DBRestClient *restClient;

@end
