//
//  VMFlipsideViewController.h
//  VoiceMessage
//
//  Created by satoshi on 2012/12/02.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VMInputSubjectViewController;

@protocol VMInputSubjectViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(VMInputSubjectViewController *)controller;
@end

@interface VMInputSubjectViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) id <VMInputSubjectViewControllerDelegate> delegate;

@property (strong,nonatomic) IBOutlet UITextField *textRecipient;
@property (strong,nonatomic) IBOutlet UITextField *textSubject;
@property (strong,nonatomic) IBOutlet UITextView *textMessage;
@property (strong, nonatomic)IBOutlet UIButton *numRecordedBadgeButton;

@property (strong,nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (strong,nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;

@property (assign, atomic)BOOL isClearText;

- (IBAction)tapGestureRecognizer:(UITapGestureRecognizer*)gestureRecognizer;
- (IBAction)swipeDownGestureRecognizer:(UISwipeGestureRecognizer*)gestureRecognizer;

- (IBAction)badgeTapped:(id)sender;

@end
