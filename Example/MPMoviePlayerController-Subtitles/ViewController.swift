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
    @IBAction func showVideo(_ sender: UIButton) {
        
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
        
    }

}

