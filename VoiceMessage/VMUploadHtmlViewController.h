//
//  VMUploadHtmlViewController.h
//  VoiceMessage
//
//  Created by satoshi on 2012/12/06.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "BitlyURLShortener.h"


@interface VMUploadHtmlViewController : UIViewController <DBRestClientDelegate,UIAlertViewDelegate, BitlyURLShortenerDelegate> {
    NSString *uploadingPath;
}
@property (strong,nonatomic)    NSString *linkForVoice;
@property (strong,nonatomic) DBRestClient *restClient;
@end
