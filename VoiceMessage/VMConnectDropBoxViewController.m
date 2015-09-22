//
//  VMMainViewController.m
//  VoiceMessage
//
//  Created by satoshi on 2012/12/02.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "VMConnectDropBoxViewController.h"
#import "UTility.h"

@interface VMConnectDropBoxViewController ()

@end

@implementation VMConnectDropBoxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    VMLogMin();
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
    
    if (![[DBSession sharedSession] isLinked]) {
        [NSTimer scheduledTimerWithTimeInterval:0.2
                                         target:self
                                       selector:@selector(authenticateDropBox:)
                                       userInfo:nil
                                        repeats:NO];
    }
    else{
        VMLogM(@"init new db client.");
        self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        self.restClient.delegate = self;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self downloadIndexHtml];
    }    
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) authenticateDropBox:(NSTimer*) timer{
    [[DBSession sharedSession] linkFromController:self];
}

- (void) downloadIndexHtml{
    VMLogMin();
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *url = [UTility applicationHiddenDocumentsDirectory];
    url = [url URLByAppendingPathComponent:@"index.html"];
    
    // index.htmlの削除
    if ([fm fileExistsAtPath:[url path]]) {
        NSError *error;
        if (![fm removeItemAtURL:url error:&error]) {
            NSLog(@"Error:removeItemAtURL:%@:%@",[error localizedDescription],[error localizedFailureReason]);
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.restClient loadFile:[defaults objectForKey:@"htmlDir"]
                     intoPath:[url path]];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath {
    VMLog(@"in. cient[%@] file[%@]", client, destPath);
    // index.html のダウンロード成功。次の画面へ
    [self gotoRecord];
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    // index.htmlのダウンロード失敗。DropBoxに無いので、リソースからアップロード。
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *url = [UTility applicationHiddenDocumentsDirectory];

    if ([fm fileExistsAtPath:[url path]]) {
        if (![fm removeItemAtURL:url error:&error]) {
            NSLog(@"Error:removeItemAtURL:%@:%@",[error localizedDescription],[error localizedFailureReason]);
            assert(NO);
        }
    }
    
    NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    if (![fm copyItemAtPath:srcPath toPath:[url path] error:&error]) {
        NSLog(@"Error:copyItemAtPath:%@:%@",[error localizedDescription],[error localizedFailureReason]);
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.restClient uploadFile:@"index.html"
                         toPath:[defaults objectForKey:@"vmHomeDir"]
                  withParentRev:nil
                       fromPath:[url path]];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath {
    
    // アップロードの成功。次の画面へ
    [self gotoRecord];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    // アップロードの失敗。次の画面へ
    [self gotoRecord];
}

- (void) gotoRecord {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"recordView"];
    [self.navigationController pushViewController:controller animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(VMInputSubjectViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"recordView"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

@end
