//
//  VMRecordingViewController.m
//  VoiceMessage
//
//  Created by satoshi on 2012/12/04.
//  Copyright (c) 2012年 satoshi. All rights reserved.
//

#import "VMRecordingViewController.h"
#import "UTility.h"

@interface VMRecordingViewController ()
- (IBAction) startRecording;
- (IBAction) stopRecording;
@end

@implementation VMRecordingViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"中止" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    
    [self beginRecordingSound];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRecording];
}

- (void) beginRecordingSound{
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
        NSLog(@"Fail:prepareToRecord");
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
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction) stopRecording
{
	[recorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
	NSLog (@"audioRecorderDidFinishRecording:successfully:%@",(flag?@"YES":@"NO"));
    [self endRecordingSound];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self stopRecording];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
