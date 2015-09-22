//
//  VMUploadHtmlViewController.m
//  VoiceMessage
//
//  Created by satoshi on 2012/12/06.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "VMUploadHtmlViewController.h"
#import "UTility.h"
#import "VMShortURLViewController.h"
#import "VMSendMailViewController.h"


@interface VMUploadHtmlViewController ()

@property (strong,nonatomic) BitlyURLShortener *bitly;
@property (strong,nonatomic) NSURL *urlToBeShorten;

@end


@implementation VMUploadHtmlViewController

@synthesize bitly;
@synthesize urlToBeShorten;

- (void)viewDidLoad
{
    [super viewDidLoad];
    uploadingPath = nil;

	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationItem.hidesBackButton = YES;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"中止" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];

    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    [self buildHtml];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (IBAction)done:(id)sender{
    if (uploadingPath!=nil) {
        [self.restClient cancelFileUpload:uploadingPath];
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void) buildHtml {
    
    NSURL *url = [UTility applicationHiddenDocumentsDirectory];
    url = [url URLByAppendingPathComponent:@"index.html"];
    
    NSError *error;
    NSStringEncoding encoding;
    NSString *html = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error];
    if (html==nil) {
        NSLog(@"Error:stringWithContentsOfURL:%@:%@",[error localizedDescription],[error localizedFailureReason]);
        NSString *message = [NSString stringWithFormat:@"index.htmlの読み込みに失敗しました:%@",[error localizedDescription]];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *recipient = [defaults objectForKey:@"recipient"];
    NSString *subject = [defaults objectForKey:@"subject"];
    NSString *message = [defaults objectForKey:@"message"];
    
    html = [html stringByReplacingOccurrencesOfString:@"$recipient" withString:recipient];
    html = [html stringByReplacingOccurrencesOfString:@"$subject" withString:subject];
    html = [html stringByReplacingOccurrencesOfString:@"$message" withString:message];
    html = [html stringByReplacingOccurrencesOfString:@"$sound" withString:self.linkForVoice];
    
    NSURL *srcURL = [UTility applicationHiddenDocumentsDirectory];
    srcURL = [srcURL URLByAppendingPathComponent:@"result.html"];
    
    // 先にファイルの削除
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[srcURL path]]) {
        NSError *error;
        if (![fm removeItemAtURL:srcURL error:&error]) {
            NSLog(@"Error:removeItemAtURL:%@:%@",[error localizedDescription],[error localizedFailureReason]);
        }
    }
    
    // htmlの保存
    if (![fm createFileAtPath:[srcURL path] contents:[html dataUsingEncoding:encoding] attributes:nil] ){
        NSLog(@"Error:createFileAtPath");
        assert(false);
    }
    
    // アップロード
    [self upload];
}

- (void) upload {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dc = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                       fromDate:[NSDate date]];
    NSString *filename = [NSString stringWithFormat:@"%04d%02d%02d%02d%02d%02d.html",[dc year],[dc month],[dc day],[dc hour],[dc minute],[dc second]];
    
    NSURL *url = [UTility applicationHiddenDocumentsDirectory];
    url = [url URLByAppendingPathComponent:@"result.html"];

    uploadingPath = [url path];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.restClient uploadFile:filename
                         toPath:[defaults objectForKey:@"vmHomeDir"]
                  withParentRev:nil
                       fromPath:[url path]];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath {
    
    [self.restClient loadSharableLinkForFile:destPath shortUrl:NO];
    uploadingPath = nil;
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {

    uploadingPath = nil;
    NSString *message = [NSString stringWithFormat:@"HTMLのアップロードに失敗しました:%@",[error localizedDescription]];
    NSLog(@"%@",message);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)restClient:(DBRestClient *)restClient loadedSharableLink:(NSString *)link forFile:(NSString *)path {

    NSLog(@"HTML uploaded successfully. link[%@]", link);
    NSString *dlLink = [[link stringByReplacingOccurrencesOfString:@"www." withString:@"dl."] stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
/*
    // アップロードの成功。次の画面へ
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    VMShortURLViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"gettingShortURL"];
    controller.urlToBeShorten = [NSURL URLWithString:dlLink];
    [self.navigationController pushViewController:controller animated:NO];
*/
    
    self.bitly = [[BitlyURLShortener alloc] init];
    self.bitly.delegate = self;
    self.urlToBeShorten = [NSURL URLWithString:dlLink];;
    
    [self.bitly shortenURL:self.urlToBeShorten];
}

- (void)restClient:(DBRestClient *)restClient loadSharableLinkFailedWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"DropBox上のファイルへのリンクの取得に失敗しました:%@",[error localizedDescription]];
    NSLog(@"%@",message);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -BitlyURLShortenerDelegate

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


@end
