//
//  VMRecordingViewController.h
//  VoiceMessage
//
//  Created by satoshi on 2012/12/04.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface VMRecordingViewController : UIViewController <AVAudioRecorderDelegate,UIAlertViewDelegate>
{
	NSMutableDictionary *recordSetting;
	NSMutableDictionary *editedObject;
	NSString *recorderFilePath;
	AVAudioRecorder *recorder;
}

@property (strong, nonatomic)IBOutlet UILabel *timerLabel;
@property (strong, nonatomic)IBOutlet UIView *confirmView;
@property (strong, nonatomic)IBOutlet UIButton *stopRecordingButton;
@property (strong, nonatomic)IBOutlet UIButton *numRecordedBadgeButton;

@end
