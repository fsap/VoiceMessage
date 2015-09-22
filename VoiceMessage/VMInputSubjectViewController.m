//
//  VMFlipsideViewController.m
//  VoiceMessage
//
//  Created by satoshi on 2012/12/02.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "VMInputSubjectViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "VMUploadSoundViewController.h"
#import "UTility.h"

@interface VMInputSubjectViewController ()

- (void)clearText;

- (void)updateBadge:(NSInteger)numRecorded;
@end


@implementation VMInputSubjectViewController

@synthesize textMessage;
@synthesize textSubject;
@synthesize textRecipient;
//@synthesize isClearText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.isClearText = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    VMLogMin();
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
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
    
    NSInteger numRecorded = [[defaults objectForKey:@"numRecorded"] intValue];
    [self updateBadge:numRecorded];

/*
    if (self.view.frame.size.height>480) {
        // iPhone5
        CGRect messageBoxFrame = self.textMessage.frame;
        messageBoxFrame.size.height = 128;
        self.textMessage.frame = messageBoxFrame;
    }
*/
    [self.textRecipient becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    VMLog(@"in. clear[%d][%d]", self.isClearText, YES);
    [super viewDidAppear:animated];
    
//    if (isClearText) {
//        [self clearText];
//    }
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
            [self.textSubject endEditing:NO];
//            [self.textMessage becomeFirstResponder];
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


#pragma mark -IBAction

- (void)badgeTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numRecorded = [[defaults objectForKey:@"numRecorded"] intValue];
    
    if (numRecorded >= 1) {
        NSString *recipient = [defaults objectForKey:@"recipient_01"];
        NSString *subject = [defaults objectForKey:@"subject_01"];

        [defaults setObject:recipient forKey:@"recipient"];
        [defaults setObject:subject forKey:@"subject"];
        [defaults synchronize];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *url = [UTility applicationHiddenDocumentsDirectory];
        NSString *tmpFileName = [NSString stringWithFormat:@"tmp_%02d.m4a", numRecorded];
        NSURL *fromUrl = [url URLByAppendingPathComponent:tmpFileName];
        NSURL *toUrl = [url URLByAppendingPathComponent:RECORDED_FILENAME];
        NSError *error;
        if ([fileManager copyItemAtPath:[fromUrl path] toPath:[toUrl path] error:&error]) {
            VMLogM(@"prepare upload ok.");
        }
        else {
            VMLog(@"failed to copy. [%@]", error);
        }


        VMUploadSoundViewController *uploadController = [self.storyboard instantiateViewControllerWithIdentifier:@"UploadSound"];
        [self.navigationController pushViewController:uploadController animated:YES];
    }
}


#pragma mark -Private

- (void)clearText {
    VMLogMin();
//    self.isClearText = YES;
    VMLog(@"in. clear[%d]", self.isClearText);
    [self.textRecipient setText:@"YES"];
    [self.textSubject setText:@""];
    [self.textMessage setText:@""];
}

- (void)updateBadge:(NSInteger)numRecorded {
    if (numRecorded > 0) {
        self.numRecordedBadgeButton.hidden = NO;
        
        // ToDo:バッジ数更新(Labelに分離)
    }
    else {
        self.numRecordedBadgeButton.hidden = YES;
    }
}


@end
