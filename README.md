MPMoviePlayerController-Subtitles
=================================

Easy way to show SRT files on MPMoviePlayerController

![MPMoviePlayerController-Subtitles](https://raw.github.com/mhergon/MPMoviePlayerController-Subtitles/master/Others/screenshot.png "")
## Usage ##

Import 
```objective-c
    #import "MPMoviePlayerController+Subtitles.h" 
```
    
Use it!
```objective-c
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
```                               

## Architecture ##
```objective-c
    // Process string and prepare to play with video 
    - (void)openWithSRTString:(NSString*)srtString completion:(void (^)(BOOL finished))success failure:(void (^)(NSError *error))failure;
    
    // Open subtitle file and prepare to play with video 
    - (void)openSRTFileAtPath:(NSString *)localFile completion:(void (^)(BOOL finished))success failure:(void (^)(NSError *error))failure;
    
    // Show subtitles
    - (void)showSubtitles;
    
    // Hide subtitles
    - (void)hideSubtitles;
```

## Requirements ##
Requires Xcode 5, targeting either iOS 6.0 and above

## Contact ##

 - [Marc Hervera][2] ([@mhergon][3])

  [2]: http://github.com/mhergon "Marc Hervera"
  [3]: http://twitter.com/mhergon "Marc Hervera"


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/mhergon/mpmovieplayercontroller-subtitles/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

