//
//  MPMoviePlayerController+Subtitles.h
//  MPMoviePlayerControllerSubtitles
//
//  Created by mhergon on 03/12/13.
//  Copyright (c) 2013 mhergon. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface MPMoviePlayerController (Subtitles)

#pragma mark - Methods
- (void)openWithSRTString:(NSString *)srtString completion:(void (^)(BOOL finished))success failure:(void (^)(NSError *error))failure;
- (void)openSRTFileAtPath:(NSString *)localFile completion:(void (^)(BOOL finished))success failure:(void (^)(NSError *error))failure;
- (void)showSubtitles;
- (void)hideSubtitles;

@end

