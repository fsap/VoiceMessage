//
//  VMSendMailViewController.h
//  VoiceMessage
//
//  Created by satoshi on 2012/12/04.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface VMSendMailViewController : UIViewController <MFMailComposeViewControllerDelegate,UIAlertViewDelegate>
@property (strong,nonatomic) NSString *shortendURLString;
@property (strong,nonatomic) MFMailComposeViewController *composer;
@end
