//
//  VMShortURLViewController.h
//  VoiceMessage
//
//  Created by satoshi on 2012/12/06.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BitlyURLShortener.h"

@interface VMShortURLViewController : UIViewController <BitlyURLShortenerDelegate,UIAlertViewDelegate> {
    BOOL    stopButtonTapped;
}
@property (strong,nonatomic) BitlyURLShortener *bitly;
@property (strong,nonatomic) NSURL *urlToBeShorten;
@end
