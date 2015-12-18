//
//  ViewController.swift
//  MPMoviePlayerController-Subtitles
//
//  Created by mhergon on 15/11/15.
//  Copyright © 2015 mhergon. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Actions
    @IBAction func showVideo(sender: UIButton) {
        
        // Video file
        let videoFile = NSBundle.mainBundle().pathForResource("trailer_720p", ofType: "mov")
        
        // Subtitle file
        let subtitleFile = NSBundle.mainBundle().pathForResource("trailer_720p", ofType: "srt")
        let subtitleURL = NSURL(fileURLWithPath: subtitleFile!)
        
        // Movie player
        let moviePlayerView = MPMoviePlayerViewController(contentURL: NSURL(fileURLWithPath: videoFile!))
        presentMoviePlayerViewControllerAnimated(moviePlayerView)
        
        // Add subtitles
        moviePlayerView.moviePlayer.addSubtitles().open(file: subtitleURL)
        moviePlayerView.moviePlayer.addSubtitles().open(file: subtitleURL, encoding: NSUTF8StringEncoding)
        
        // Change text properties
        moviePlayerView.moviePlayer.subtitleLabel?.textColor = UIColor.redColor()
        
        // Play
        moviePlayerView.moviePlayer.play()
        
    }

}

