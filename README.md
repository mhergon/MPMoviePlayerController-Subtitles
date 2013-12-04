MPMoviePlayerController-Subtitles
=================================

Easy way to show SRT files on MPMoviePlayerController

![image alt][1]
## Usage ##

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

## Architecture ##
    // Open subtitle file and prepare to play with video 
    - (void)openSRTFileAtPath:(NSString *)localFile completion:(void (^)(BOOL finished))success failure:(void (^)(NSError *error))failure;
    
    // Show subtitles
    - (void)showSubtitles;
    
    // Hide subtitles
    - (void)hideSubtitles;

## Requirements ##
Requires Xcode 5, targeting either iOS 6.0 and above

## Contact ##

 - [Marc Hervera][1] ([@mhergon][1])
  [1]: http://github.com/mhergon "Marc Hervera"
  [2]: http://twitter.com/mhergon "Marc Hervera"
