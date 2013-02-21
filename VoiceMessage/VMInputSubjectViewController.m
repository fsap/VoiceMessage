//
//  VMFlipsideViewController.m
//  VoiceMessage
//
//  Created by satoshi on 2012/12/02.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "VMInputSubjectViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface VMInputSubjectViewController ()

@end

@implementation VMInputSubjectViewController

- (void)viewDidLoad
{
    VMLogMin();
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;

    self.textMessage.layer.cornerRadius = 8;
    self.textMessage.clipsToBounds = YES;
    self.textMessage.layer.borderWidth = 2;
    self.textMessage.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *recipient = [defaults objectForKey:@"recipient"];
    self.textRecipient.text = recipient;
    
    NSString *subject = [defaults objectForKey:@"subject"];
    self.textSubject.text = subject;
    
    NSString *message = [defaults objectForKey:@"message"];
    self.textMessage.text = message;

    if (self.view.frame.size.height>480) {
        // iPhone5
        CGRect messageBoxFrame = self.textMessage.frame;
        messageBoxFrame.size.height = 128;
        self.textMessage.frame = messageBoxFrame;
    }
    
    [self.textRecipient becomeFirstResponder];
 }

- (IBAction)done:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField==self.textRecipient) {
        [self.textSubject becomeFirstResponder];
        return YES;
    }
    else if (textField==self.textSubject) {
        if ([textField.text length]>0) {
            [self.textMessage becomeFirstResponder];
            return YES;
        }
        else{
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (textField==self.textRecipient) {
        [defaults setObject:textField.text forKey:@"recipient"];
    }
    else if (textField==self.textSubject) {
        [defaults setObject:textField.text forKey:@"subject"];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {

    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"message"];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:textView.text forKey:@"message"];
}


#pragma mark -Selector

- (IBAction)tapGestureRecognizer:(UITapGestureRecognizer*)gestureRecognizer{
    [self.textMessage resignFirstResponder];
}

- (IBAction)swipeDownGestureRecognizer:(UISwipeGestureRecognizer*)gestureRecognizer {
    [self.textRecipient resignFirstResponder];
    [self.textMessage resignFirstResponder];

    if ([self.textSubject.text length]>0) {
        [self.textSubject resignFirstResponder];
    }
    else{
        [self.textSubject becomeFirstResponder];
    }
}

@end
