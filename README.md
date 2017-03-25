<p align="center" >
<img src="https://raw.github.com/mhergon/MPMoviePlayerController-Subtitles/master/assets/logo.png" alt="Logo" title="Logo" width=250>
</p>

![issues](https://img.shields.io/github/issues/mhergon/MPMoviePlayerController-Subtitles.svg)
&emsp;
![stars](https://img.shields.io/github/stars/mhergon/MPMoviePlayerController-Subtitles.svg)
&emsp;
![license](https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg)


MPMoviePlayerController-Subtitles is a library to display subtitles on iOS. It's built as a Swift extension and it's very easy to integrate.

## How To Get Started

### Installation with CocoaPods

```ruby
platform :ios, '8.0'
pod "MPMoviePlayerController-Subtitles"
```

### Manually installation

[Download](https://github.com/mhergon/MPMoviePlayerController-Subtitles/raw/master/MPMoviePlayerController-Subtitles.swift) (right-click) and add to your project.

### Requirements

| Version | Language  | Minimum iOS Target  |
|:--------------------:|:---------------------------:|:---------------------------:|
|          2.2.x         |            Swift 3.x            |            iOS 8            |
|          2.0.x         |            Swift 2.x            |            iOS 8            |
|          1.x         |            Objective-C            |            iOS 6            |


### Usage with player

```swift
import MPMoviePlayerControllerSubtitles
```

```swift
// Video file
let videoFile = Bundle.main.path(forResource: "trailer_720p", ofType: "mov")

// Subtitle file
let subtitleFile = Bundle.main.path(forResource: "trailer_720p", ofType: "srt")
let subtitleURL = URL(fileURLWithPath: subtitleFile!)

// Movie player
let moviePlayerView = MPMoviePlayerViewController(contentURL: URL(fileURLWithPath: videoFile!))
presentMoviePlayerViewControllerAnimated(moviePlayerView)

// Add subtitles
moviePlayerView?.moviePlayer.addSubtitles().open(file: subtitleURL)
moviePlayerView?.moviePlayer.addSubtitles().open(file: subtitleURL, encoding: String.Encoding.utf8)

// Change text properties
moviePlayerView?.moviePlayer.subtitleLabel?.textColor = UIColor.red

// Play
moviePlayerView?.moviePlayer.play()
```

#### Screenshot
<p align="center" >
<img src="https://raw.github.com/mhergon/MPMoviePlayerController-Subtitles/master/assets/screenshot.png" alt="Screenshoot" title="Screenshoot">
</p>

### Usage without player

From version 2.2 you can search text in the SubRip file or text without need play any file.

```swift
import MPMoviePlayerControllerSubtitles
```

```swift
// Subtitle file
let subtitleFile = Bundle.main.path(forResource: "trailer_720p", ofType: "srt")
let subtitleURL = URL(fileURLWithPath: subtitleFile!)

// Subtitle parser
let parser = Subtitles(file: subtitleURL, encoding: .utf8)

// Do something with result
let subtitles = parser.searchSubtitles(at: 2.0) // Search subtitle at 2.0 seconds
```

## Contact

- [Linkedin][2]
- [Twitter][3] (@mhergon)

[2]: https://es.linkedin.com/in/marchervera
[3]: http://twitter.com/mhergon "Marc Hervera"

## License

Licensed under Apache License v2.0.
<br>
Copyright 2017 Marc Hervera.
