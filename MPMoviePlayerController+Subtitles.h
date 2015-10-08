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
- (void)openSRTFileAtPath:(NSDictionary *)localFilesDictionary completion:(void (^)(BOOL finished))success failure:(void (^)(NSError *error))failure;
- (void)openWithSRTString:(NSDictionary *)srtStringsDictionary completion:(void (^)(BOOL finished))success failure:(void (^)(NSError *error))failure;
- (BOOL)showSubtitlesWithOption:(enum LanguageOption)option;
- (BOOL)hideSubtitles;

@end

