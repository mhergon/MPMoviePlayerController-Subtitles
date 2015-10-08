//
//  MPMoviePlayerController+Subtitles.m
//  MPMoviePlayerControllerSubtitles
//
//  Created by mhergon on 03/12/13.
//  Copyright (c) 2013 mhergon. All rights reserved.
//

#import "MPMoviePlayerController+Subtitles.h"
#import <objc/runtime.h>

static NSString *const kIndex = @"kIndex";
static NSString *const kStart = @"kStart";
static NSString *const kEnd = @"kEnd";
static NSString *const kText = @"kText";


@interface MPMoviePlayerViewController ()

#pragma mark - Properties
@property (strong, nonatomic) NSMutableDictionary *subtitlesParts;
@property (strong, nonatomic) NSMutableDictionary *currentLanguageSubtitleParts;
@property (strong, nonatomic) NSTimer *subtitleTimer;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (nonatomic) enum LanguageOption languageOption;

#pragma mark - Private methods
- (BOOL)needToShowSubtitles:(BOOL)show;
- (void)parseString:(NSString *)string parsed:(void (^)(BOOL parsed, NSError *error))completion;
- (NSTimeInterval)timeFromString:(NSString *)timeString;
- (void)searchAndShowSubtitle;
- (void)updateLabelHeight;

#pragma mark - Notifications
- (void)playbackStateDidChange:(NSNotification *)notification;
- (void)playbackDidFinish:(NSNotification *)notification;
- (void)orientationWillChange:(NSNotification *)notification;
- (void)orientationDidChange:(NSNotification *)notification;
- (void)willEnterFullscreen:(NSNotification *)notification;
- (void)didEnterFullscreen:(NSNotification *)notification;
- (void)willExitFullscreen:(NSNotification *)notification;


@end

@implementation MPMoviePlayerController (Subtitles)

#pragma mark - Methods
- (void)openSRTFileAtPath:(NSDictionary *)localFilesDictionary completion:(void (^)(BOOL finished))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *srtFilesInStringForm = [NSMutableDictionary dictionary];
    
    // Error
    NSError *error = nil;
    
    for (NSString *key in [localFilesDictionary allKeys])
    {
        // File to string
        NSString *subtitleString = [NSString stringWithContentsOfFile:[localFilesDictionary objectForKey:key]
                                                             encoding:NSUTF8StringEncoding
                                                                error:&error];
        
        //SRT Files hidden characters are coming in two flavours. So here we are syncing them.
        //So that our SRT parser behaves correctly.
        subtitleString = [subtitleString stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\r\n\r\n"];
        if (error && failure != NULL)
        {
            failure(error);
            return;
        }
        [srtFilesInStringForm setObject:subtitleString forKey:key];
    }
    
    // Parse and show text
    [self openWithSRTString:srtFilesInStringForm completion:success failure:failure];
}

- (void)openWithSRTString:(NSDictionary *)srtStringsDictionary completion:(void (^)(BOOL finished))success failure:(void (^)(NSError *error))failure{
    
    [self parseString:srtStringsDictionary
               parsed:^(BOOL parsed, NSError *error) {
                   
                   if (!error && success != NULL) {
                       
                       // Register for notifications
                       [[NSNotificationCenter defaultCenter] addObserver:self
                                                                selector:@selector(playbackStateDidChange:)
                                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                                  object:nil];
                       
                       [[NSNotificationCenter defaultCenter] addObserver:self
                                                                selector:@selector(orientationWillChange:)
                                                                    name:UIApplicationWillChangeStatusBarFrameNotification
                                                                  object:nil];
                       
                       [[NSNotificationCenter defaultCenter] addObserver:self
                                                                selector:@selector(orientationDidChange:)
                                                                    name:UIDeviceOrientationDidChangeNotification
                                                                  object:nil];
                       
                       [[NSNotificationCenter defaultCenter] addObserver:self
                                                                selector:@selector(playbackDidFinish:)
                                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                                  object:nil];
                       
                       [[NSNotificationCenter defaultCenter] addObserver:self
                                                                selector:@selector(willEnterFullscreen:)
                                                                    name:MPMoviePlayerWillEnterFullscreenNotification
                                                                  object:nil];
                       
                       [[NSNotificationCenter defaultCenter] addObserver:self
                                                                selector:@selector(didEnterFullscreen:)
                                                                    name:MPMoviePlayerDidEnterFullscreenNotification
                                                                  object:nil];
                       
                       [[NSNotificationCenter defaultCenter] addObserver:self
                                                                selector:@selector(willExitFullscreen:)
                                                                    name:MPMoviePlayerWillExitFullscreenNotification
                                                                  object:nil];


                       if (success != NULL) {
                           success(YES);
                       }
                       
                   } else if (error && failure != NULL) {
                       
                       if (failure != NULL) {
                           failure(error);
                       }
                       
                   }
                   
               }];
    
}

- (BOOL)needToShowSubtitles:(BOOL)show
{
    BOOL success = NO;
    if (self.subtitleLabel)
    {
        // Hide label
        self.subtitleLabel.hidden = !show;
        success = YES;
    }
    return success;
}

- (BOOL)showSubtitlesWithOption:(enum LanguageOption)option
{
    switch (option)
    {
        case ENGLISH:
        {
            self.currentLanguageSubtitleParts = [self.subtitlesParts objectForKey:@"en"];
            break;
        }
        case SPANISH:
        {
            self.currentLanguageSubtitleParts = [self.subtitlesParts objectForKey:@"es"];
            break;
        }
        default:
            break;
    }
    return [self needToShowSubtitles:YES];
}

- (BOOL)hideSubtitles
{
    return [self needToShowSubtitles:NO];
}

#pragma mark - Private methods
- (void)parseString:(NSDictionary *)srtStringsDictionary parsed:(void (^)(BOOL parsed, NSError *error))completion {
    
    self.subtitlesParts = [NSMutableDictionary dictionary];
    for (NSString *key in [srtStringsDictionary allKeys])
    {
        NSString *scannableString = [srtStringsDictionary objectForKey:key];
        
        // Subtitles parts
        NSMutableDictionary *subtitleParts = [NSMutableDictionary dictionary];
        
        // Create Scanner
        NSScanner *scanner = [NSScanner scannerWithString:scannableString];
        if (scanner != nil)
        {
            // Search for members
            while (!scanner.isAtEnd)
            {
                // Variables
                NSString *indexString;
                [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
                                        intoString:&indexString];
                NSString *startString;
                [scanner scanUpToString:@" --> " intoString:&startString];
                [scanner scanString:@"-->" intoString:NULL];
                
                NSString *endString;
                [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
                                        intoString:&endString];
                
                NSString *textString;
                [scanner scanUpToString:@"\r\n\r\n" intoString:&textString];
                textString = [textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                // Regular expression to replace tags
                NSError *error = nil;
                NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"[<|\\{][^>|\\^}]*[>|\\}]"
                                                                                        options:NSRegularExpressionCaseInsensitive
                                                                                          error:&error];
                if (error)
                {
                    completion(NO, error);
                    return;
                }
                
                textString = [regExp stringByReplacingMatchesInString:textString.length > 0 ? textString : @""
                                                              options:0
                                                                range:NSMakeRange(0, textString.length)
                                                         withTemplate:@""];
                
                // Temp object
                NSTimeInterval startInterval = [self timeFromString:startString];
                NSTimeInterval endInterval = [self timeFromString:endString];
                NSDictionary *tempInterval = @{
                                               kIndex : indexString,
                                               kStart : @(startInterval),
                                               kEnd : @(endInterval),
                                               kText : textString ? textString : @""
                                               };
                [subtitleParts setObject:tempInterval
                                  forKey:indexString];
            }
        }
        [self.subtitlesParts setObject:subtitleParts forKey:key];
    }
    if (completion != NULL)
    {
        completion(YES, nil);
    }
}

- (NSTimeInterval)timeFromString:(NSString *)timeString {
    
    NSScanner *scanner = [NSScanner scannerWithString:timeString];
    
    int h, m, s, c;
    [scanner scanInt:&h];
    [scanner scanString:@":" intoString:NULL];
    [scanner scanInt:&m];
    [scanner scanString:@":" intoString:NULL];
    [scanner scanInt:&s];
    [scanner scanString:@"," intoString:NULL];
    [scanner scanInt:&c];
    
    return (h * 3600) + (m * 60) + s + (c / 1000.0);
    
}

- (void)searchAndShowSubtitle {
    
    NSDictionary *subtitleParts = self.currentLanguageSubtitleParts;
    
    // Search for timeInterval
    NSPredicate *initialPredicate = [NSPredicate predicateWithFormat:@"(%@ >= %K) AND (%@ <= %K)", @(self.currentPlaybackTime), kStart, @(self.currentPlaybackTime), kEnd];
    NSArray *objectsFound = [[subtitleParts allValues] filteredArrayUsingPredicate:initialPredicate];
    NSDictionary *lastFounded = (NSDictionary *)[objectsFound lastObject];
    
    // Show text
    if (lastFounded)
    {
        // Get text
        self.subtitleLabel.text = [lastFounded objectForKey:kText];
        
        // Label position
        CGSize size = [self.subtitleLabel.text sizeWithFont:self.subtitleLabel.font
                                          constrainedToSize:CGSizeMake(CGRectGetWidth(self.subtitleLabel.bounds), CGFLOAT_MAX)];
        self.subtitleLabel.frame = ({
            CGRect frame = self.subtitleLabel.frame;
            frame.size.height = size.height;
            frame;
        });
        self.subtitleLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(self.view.bounds) - (CGRectGetHeight(self.subtitleLabel.bounds) / 2.0) - 145.0);
    }
    else
    {
        self.subtitleLabel.text = @"";
    }
    
}

- (void)updateLabelConstraints {
    
    // Default
    NSString *horizontal = @"H:|-(15)-[weakSubtitleLabel]-(15)-|";
    NSString *vertical = @"V:[weakSubtitleLabel]-(15)-|";
    
    UIView __weak *weakSubtitleLabel = self.subtitleLabel;
    NSDictionary *views = NSDictionaryOfVariableBindings(weakSubtitleLabel);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:horizontal
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views];
    [self.subtitleLabel.superview addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:vertical
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self.subtitleLabel.superview addConstraints:constraints];
    
    
    CGRect bounds = [self.subtitleLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.subtitleLabel.bounds), CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName : self.subtitleLabel.font}
                                                          context:nil];
    self.heightConstraint.constant = bounds.size.height + 10.0;

    [self.subtitleLabel.superview layoutIfNeeded];
    
}

#pragma mark - Notifications
- (void)playbackStateDidChange:(NSNotification *)notification {
    
    switch (self.playbackState) {
            
        case MPMoviePlaybackStateStopped: {
            
            // Stop
            if (self.subtitleTimer.isValid) {
                [self.subtitleTimer invalidate];
            }
            
            break;
        }
            
        case MPMoviePlaybackStatePlaying: {
            
            // Start timer
            self.subtitleTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                  target:self
                                                                selector:@selector(searchAndShowSubtitle)
                                                                userInfo:nil
                                                                 repeats:YES];
            [self.subtitleTimer fire];
            
            
            // Add label
            if (!self.subtitleLabel) {
                
                // Add label
                CGFloat fontSize = 0.0;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    fontSize = 40.0;
                } else {
                    fontSize = 20.0;
                }
                self.subtitleLabel = [[UILabel alloc] init];
                self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
                self.subtitleLabel.backgroundColor = [UIColor clearColor];
                self.subtitleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
                self.subtitleLabel.textColor = [UIColor whiteColor];
                self.subtitleLabel.numberOfLines = 0;
                self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
                self.subtitleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
                self.subtitleLabel.layer.shadowOffset = CGSizeMake(6.0, 6.0);
                self.subtitleLabel.layer.shadowOpacity = 0.9;
                self.subtitleLabel.layer.shadowRadius = 4.0;
                self.subtitleLabel.layer.shouldRasterize = YES;
                self.subtitleLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
                [self.view addSubview:self.subtitleLabel];
                
                // Update label constraints
                [self updateLabelConstraints];
                
            }
            
            break;
        }
            
        default: {
            
            break;
        }
            
    }
    
}

- (void)playbackDidFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.subtitleTimer invalidate];
    self.subtitleTimer = nil;
    [self removeAssociatedObjects];
    
}

- (void)orientationWillChange:(NSNotification *)notification {
    
    // Hidden label
    self.subtitleLabel.hidden = YES;
    
}

- (void)orientationDidChange:(NSNotification *)notification {
    
    // Show label
    self.subtitleLabel.hidden = NO;

    // Update label constraints
    [self updateLabelConstraints];
 
}

- (void)willEnterFullscreen:(NSNotification *)notification {
    
    // Hidden label
    self.subtitleLabel.hidden = YES;

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    [window addSubview:self.subtitleLabel];
    
    // Update label constraints
    [self updateLabelConstraints];

}

- (void)didEnterFullscreen:(NSNotification *)notification {

    // Show label
    self.subtitleLabel.hidden = NO;
    
}

- (void)willExitFullscreen:(NSNotification *)notification {
    
    [self.view addSubview:self.subtitleLabel];
    
    // Update label constraints
    [self updateLabelConstraints];
    
}

#pragma mark - Others
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)setSubtitlesParts:(NSMutableDictionary *)subtitlesParts {
    
    objc_setAssociatedObject(self, @"subtitlesParts", subtitlesParts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (NSMutableDictionary *)subtitlesParts {
    
    return objc_getAssociatedObject(self, @"subtitlesParts");
    
}

- (void)setSubtitleTimer:(NSTimer *)timer {
    
    objc_setAssociatedObject(self, @"timer", timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (NSTimer *)subtitleTimer {
    
    return objc_getAssociatedObject(self, @"timer");
    
}

- (void)setSubtitleLabel:(UILabel *)subtitleLabel {
    
    objc_setAssociatedObject(self, @"subtitleLabel", subtitleLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (UILabel *)subtitleLabel {
    
    return objc_getAssociatedObject(self, @"subtitleLabel");
    
}

- (void)setCurrentLanguageSubtitleParts:(NSMutableDictionary *)currentLanguageSubtitleParts
{
    objc_setAssociatedObject(self, @"currentLanguageSubtitleParts", currentLanguageSubtitleParts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)currentLanguageSubtitleParts
{
    return objc_getAssociatedObject(self, @"currentLanguageSubtitleParts");
}

- (void)setHeightConstraint:(NSLayoutConstraint *)heightConstraint {
    
    objc_setAssociatedObject(self, @"heightConstraint", heightConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (NSLayoutConstraint *)heightConstraint {
    
    return objc_getAssociatedObject(self, @"heightConstraint");
    
}

- (void)removeAssociatedObjects
{
    objc_removeAssociatedObjects(self);
}

@end
