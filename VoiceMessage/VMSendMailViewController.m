//
//  VMSendMailViewController.m
//  VoiceMessage
//
//  Created by satoshi on 2012/12/04.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "VMSendMailViewController.h"
#import "UTility.h"
#import "VMInputSubjectViewController.h"


@interface VMSendMailViewController ()

@end

@implementation VMSendMailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationItem.hidesBackButton = YES;
/*
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完了"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(done:)];
*/
    self.composer = [[MFMailComposeViewController alloc] init];
    self.composer.mailComposeDelegate = self;
    
    [self sendMail];
}

- (void) sendMail {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *subject = [defaults objectForKey:@"subject"];
    NSString *recipient = [defaults objectForKey:@"recipient"];

    if ([recipient length]>0) {
        subject = [NSString stringWithFormat:@"%@様へ：%@", recipient, subject];
    }
    [self.composer setSubject:subject];

    NSString *sendTo = [defaults objectForKey:@"sendTo"];
    if ([sendTo length]>0) {
        [self.composer setToRecipients:@[sendTo]];
    }

    [self.composer setMessageBody:self.shortendURLString isHTML:NO];
    
    [self presentViewController:self.composer animated:YES completion:^{
        //
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {

    BOOL isClearText = NO;
    switch (result) {
        case MFMailComposeResultCancelled:
        {
            NSLog(@"メールの送信がキャンセルされました。");
        }
            break;
        case MFMailComposeResultFailed:
        {
            
            NSString *message = [NSString stringWithFormat:@"メールの送信に失敗しました:%@",[error localizedDescription]];
            NSLog(@"%@",message);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            
            [alertView show];
        }
            break;
        case MFMailComposeResultSaved:
        {
            NSLog(@"メールは送信されずに保存しました。");
        }
            break;
        case MFMailComposeResultSent:
        {
            isClearText = YES;
            NSLog(@"メールが送信されました。");
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"" forKey:@"recipient"];
            [defaults setObject:@"" forKey:@"subject"];
            [defaults setObject:@"" forKey:@"message"];
        }
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        VMLogMin();
        /*
        if (isClearText) {
            for (id viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[VMInputSubjectViewController class]]) {
//                    [(VMInputSubjectViewController *)viewController clearText];
                    VMLogM(@"set YES");
                    ((VMInputSubjectViewController *)viewController).isClearText = YES;
                }
            }
        }
        */
        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
}

- (IBAction)done:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
