//
//  MainViewController.m
//  MPMoviePlayerControllerSubtitles
//
//  Created by mhergon on 03/12/13.
//  Copyright (c) 2013 mhergon. All rights reserved.
//

#import "MainViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MPMoviePlayerController+Subtitles.h"

@interface MainViewController ()

- (IBAction)showVideoAction:(UIButton *)sender;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showVideoAction:(UIButton *)sender {
    
    // Video file
    NSString *filePathStr = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePathStr];
    
    // Subtitles file
    NSString *subtitlesPathStr = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"srt"];
    
    // Create MoviePlayer
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
    [player.moviePlayer openSRTFileAtPath:subtitlesPathStr
                               completion:^(BOOL finished) {
                                   
                                   // Activate subtitles
                                   [player.moviePlayer showSubtitles];
                                   
                                   // Show video
                                   [self presentMoviePlayerViewControllerAnimated:player];
                                   
                               } failure:^(NSError *error) {
                                   
                                   NSLog(@"Error: %@", error.description);
                                   
                               }];
    
}



@end
