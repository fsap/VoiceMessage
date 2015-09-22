//
//  VMUploadSoundViewController.m
//  VoiceMessage
//
//  Created by satoshi on 2012/12/06.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "VMUploadSoundViewController.h"
#import "UTility.h"
#import "VMUploadHtmlViewController.h"

#define VMUploadDirectory @"/VoiceMessage/voice"


@interface VMUploadSoundViewController ()

@end

@implementation VMUploadSoundViewController

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
    
    [self uploadSound];
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

- (void) uploadSound {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dc = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                                   fromDate:[NSDate date]];
    NSString *filename = [NSString stringWithFormat:@"vm%04d%02d%02d%02d%02d%02d.m4a",[dc year],[dc month],[dc day],[dc hour],[dc minute],[dc second]];
    
    NSURL *url = [UTility applicationHiddenDocumentsDirectory];
    url = [url URLByAppendingPathComponent:RECORDED_FILENAME];

    uploadingPath = [url path];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.restClient uploadFile:filename
                         toPath:[defaults objectForKey:@"voiceDir"]
                  withParentRev:nil
                       fromPath:[url path]];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath {

    NSLog(@"Voice uploaded successfully.");
    [self.restClient loadSharableLinkForFile:destPath shortUrl:NO];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"音声のアップロードに失敗しました:%@",[error localizedDescription]];
    NSLog(@"%@",message);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)restClient:(DBRestClient *)restClient loadedSharableLink:(NSString *)link forFile:(NSString *)path {

    NSString *dlLink = [link stringByReplacingOccurrencesOfString:@"www." withString:@"dl."];

    // アップロードの成功。次の画面へ
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    VMUploadHtmlViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"htmlUploading"];
    controller.linkForVoice = dlLink;
    [self.navigationController pushViewController:controller animated:NO];
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

@end
