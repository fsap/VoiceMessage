//
//  VMShortURLViewController.m
//  VoiceMessage
//
//  Created by satoshi on 2012/12/06.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "VMShortURLViewController.h"
#import "VMSendMailViewController.h"

@interface VMShortURLViewController ()

@end

@implementation VMShortURLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"中止" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];

    stopButtonTapped = NO;
    self.bitly = [[BitlyURLShortener alloc] init];
    self.bitly.delegate = self;

    [self.bitly shortenURL:self.urlToBeShorten];
}

- (IBAction)done:(id)sender{
    stopButtonTapped = YES;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void) bitlyURLShortenerDidShortenURL:(BitlyURLShortener *)shortener longURL:(NSURL *)longURL shortURLString:(NSString *)shortURLString {
    NSLog(@"Success:bitlyURLShortenerDidShortenURL:%@",shortURLString);

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    VMSendMailViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"sendingMail"];
    controller.shortendURLString = shortURLString;
    [self.navigationController pushViewController:controller animated:NO];
}

- (void) bitlyURLShortener:(BitlyURLShortener *)shortener didFailForLongURL:(NSURL *)longURL statusCode:(NSInteger)statusCode statusText:(NSString *)statusText {

    NSString *message = [NSString stringWithFormat:@"Bitlyでの短縮URLの取得に失敗しました:%d:%@",statusCode,statusText];
    NSLog(@"%@",message);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!stopButtonTapped) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
