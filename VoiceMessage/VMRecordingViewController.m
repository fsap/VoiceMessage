//
//  VMRecordingViewController.m
//  VoiceMessage
//
//  Created by satoshi on 2012/12/04.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "VMRecordingViewController.h"
#import "VMUploadSoundViewController.h"
#import "UTility.h"
#import "Reachability.h"

@interface VMRecordingViewController ()

@property (assign, nonatomic)CGFloat currentTime;
@property (strong, nonatomic)NSTimer *recordingTimer;

- (IBAction) startRecording;
- (IBAction) stopRecording;
- (IBAction)confirmYes:(id)sender;
- (IBAction)confirmNo:(id)sender;
- (IBAction)badgeTapped:(id)sender;
- (void)updateTime;
- (void)showConfirmView;
- (void)updateBadge:(NSInteger)numRecorded;
@end


@implementation VMRecordingViewController

@synthesize currentTime;
@synthesize recordingTimer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.currentTime = 0;
    [self updateTime];
    
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationItem.hidesBackButton = YES;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"中止" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numRecorded = [[defaults objectForKey:@"numRecorded"] intValue];
    [self updateBadge:numRecorded];
    
    [self beginRecordingSound];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRecording];
}

- (void) beginRecordingSound{
    VMLogMin();
    NSURL *url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/begin_record.caf"];
    SystemSoundID soundID;
    OSStatus status = AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    if (status==kAudioServicesNoError) {
        AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, beginRecordingSoundCompletion,(__bridge void *)(self));
        AudioServicesPlaySystemSound(soundID);
    }

}

void beginRecordingSoundCompletion(SystemSoundID soundID, void* clientData){
    AudioServicesDisposeSystemSoundID(soundID);
    
    VMRecordingViewController *aSelf = (__bridge VMRecordingViewController*)clientData;
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:aSelf
                                   selector:@selector(startRecordingTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) endRecordingSound{
    NSURL *url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/end_record.caf"];
    SystemSoundID soundID;
    OSStatus status = AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    if (status==kAudioServicesNoError) {
        AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, endRecordingSoundCompletion,(__bridge void *)(self));
        AudioServicesPlaySystemSound(soundID);
    }
    [self.recordingTimer invalidate];
}

void endRecordingSoundCompletion(SystemSoundID soundID, void* clientData){
    AudioServicesDisposeSystemSoundID(soundID);
}

- (IBAction)done:(id)sender{
    [self stopRecording];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void) startRecordingTimer:(NSTimer*)timer{
    [self startRecording];
}

- (IBAction) startRecording
{
    VMLogMin();
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"エラーが発生しました。時間を置いて再度お試しください。"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	NSError *err = nil;
	[audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        [alertView show];
        return;
	}
	[audioSession setActive:YES error:&err];
	err = nil;
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        [alertView show];
        return;
	}
	
	recordSetting = [[NSMutableDictionary alloc] init];
	
	// We can use kAudioFormatAppleIMA4 (4:1 compression) or kAudioFormatLinearPCM for nocompression
	[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    
	// We can use 44100, 32000, 24000, 16000 or 12000 depending on sound quality
	[recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
	
	// We can use 2(if using additional h/w) or 1 (iPhone only has one microphone)
	[recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
	
    NSURL *url = [UTility applicationHiddenDocumentsDirectory];
    url = [url URLByAppendingPathComponent:RECORDED_FILENAME];
	recorderFilePath = [url path];
	
	NSLog(@"recorderFilePath: %@",recorderFilePath);
	
	err = nil;
	
	NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[url path]]) {
        if (![fm removeItemAtURL:url error:&err]) {
            NSLog(@"Error:removeItmeAtURL:%@:%@",[err localizedDescription],[err localizedFailureReason]);
        }
    }
	[fm removeItemAtPath:[url path] error:&err];
	
	err = nil;
	recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
	if(!recorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: [err localizedDescription]
								  delegate: self
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [alert show];
        return;
	}
	
	//prepare to record
	[recorder setDelegate:self];
	if(![recorder prepareToRecord]){
        NSLog(@"Fail:prepareToRecord [%@]", [[NSString stringWithFormat:@"%@", recorder] description]);
        [alertView show];
        return;
    }
	
	BOOL audioHWAvailable;
    if ([[UIDevice currentDevice] systemVersion].floatValue < 6.0 ){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "deprecated-declarations"
        audioHWAvailable = audioSession.inputIsAvailable;
#pragma clang diagnostic pop
    }
    else{
        audioHWAvailable = audioSession.inputAvailable;
    }
	if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: @"Audio input hardware not available"
								  delegate: self
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
	}

	// start recording
	if( ![recorder record] ){
        NSLog(@"Fail:record");
        [alertView show];
        return;
    }
    self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
}

/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    VMLog(@"in. index[%d]", buttonIndex);
    
    if (buttonIndex == 0) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    else {
        // オンライン判定
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        switch (status) {
            case NotReachable:
                VMLogM(@"offline.");
                break;
                
            default:
                VMLogM(@"online.");
                break;
        }
        
        // ToDo:アップロード
        VMUploadSoundViewController *uploadController = [self.storyboard instantiateViewControllerWithIdentifier:@"UploadSound"];
        [self.navigationController pushViewController:uploadController animated:YES];
    }
}
*/

- (IBAction) stopRecording
{
	[recorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
	NSLog (@"audioRecorderDidFinishRecording:successfully:%@",(flag?@"YES":@"NO"));
    [self endRecordingSound];
    
    // ToDo:アラート
    [self showConfirmView];
/*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Confirm"
                                                    message: @"収録した音声を使用しますか？"
                                                   delegate: self
                                          cancelButtonTitle:@"いいえ"
                                          otherButtonTitles:@"はい", nil];
    [alert show];
*/
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self stopRecording];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Override
- (void)segue {
    VMLogMin();
}


#pragma mark -IBAction

- (void)confirmYes:(id)sender {
    // オンライン判定
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    switch (status) {
        case NotReachable:
            VMLogM(@"offline.");
        {
            // ToDo:オフライン時動作
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSInteger numRecorded = [[defaults objectForKey:@"numRecorded"] intValue];
            VMLog(@"num recorded[%d]", numRecorded);
            // とりあえず1件
            if (numRecorded > 1) {
                numRecorded = 1;
            }
            else {
                numRecorded++;
            }
            
            NSURL *url = [UTility applicationHiddenDocumentsDirectory];
            NSString *recordingFileName = [NSString stringWithFormat:@"tmp_%02d.m4a", numRecorded];
            url = [url URLByAppendingPathComponent:recordingFileName];
            VMLog(@"Temporary record file[%@]", url);
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            if ([fileManager copyItemAtPath:recorderFilePath toPath:[url path] error:&error]) {
                NSString *recipient = [defaults objectForKey:@"recipient"];
                NSString *subject = [defaults objectForKey:@"subject"];

                [defaults setInteger:numRecorded forKey:@"numRecorded"];
                [defaults setObject:recipient forKey:[NSString stringWithFormat:@"recipient_%02d", numRecorded]];
                [defaults setObject:subject forKey:[NSString stringWithFormat:@"subject_%02d", numRecorded]];

                [defaults synchronize];
            }
            else {
                VMLog(@"failed to copy. [%@]", error);
            }
            // バッジ更新
            [self updateBadge:numRecorded];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Temporary Saved"
                                                            message: @""
                                                           delegate: self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

            return;
        }
            break;
            
        default:
            VMLogM(@"online.");
            break;
    }
    
    // ToDo:アップロード
    VMUploadSoundViewController *uploadController = [self.storyboard instantiateViewControllerWithIdentifier:@"UploadSound"];
    [self.navigationController pushViewController:uploadController animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    VMLog(@"in. index[%d]", buttonIndex);
    
    if (buttonIndex == 0) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)confirmNo:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}


#pragma mark -Private

- (void)updateTime {
    self.currentTime += 0.01;
    int sec = floorf(self.currentTime);
    int min = self.currentTime / 60;
    int msec = (self.currentTime - sec) * 100;
    [self.timerLabel setText:[NSString stringWithFormat:@"%02d:%02d.%02d", min, sec % 60, msec]];
}

- (void)showConfirmView {
    self.stopRecordingButton.hidden = YES;
    self.confirmView.hidden = NO;
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
