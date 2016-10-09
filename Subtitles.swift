//
//  MPMoviePlayerController-Subtitles.swift
//  MPMoviePlayerController-Subtitles
//
//  Created by mhergon on 15/11/15.
//  Copyright © 2015 mhergon. All rights reserved.
//

import ObjectiveC
import MediaPlayer

private struct AssociatedKeys {
    static var FontKey = "FontKey"
    static var ColorKey = "FontKey"
    static var ContainerKey = "ContainerKey"
    static var SubtitleKey = "SubtitleKey"
    static var SubtitleHeightKey = "SubtitleHeightKey"
    static var PayloadKey = "PayloadKey"
    static var TimerKey = "TimerKey"
}

public extension MPMoviePlayerController {
    
    //MARK:- Public properties
    var subtitleLabel: UILabel? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleKey) as? UILabel }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    //MARK:- Private properties
    fileprivate var subtitleContainer: UIView? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.ContainerKey) as? UIView }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.ContainerKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    fileprivate var subtitleLabelHeightConstraint: NSLayoutConstraint? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey) as? NSLayoutConstraint }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    fileprivate var parsedPayload: NSDictionary? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.PayloadKey) as? NSDictionary }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.PayloadKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    fileprivate var timer: Timer? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.TimerKey) as? Timer }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.TimerKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    //MARK:- Public methods
    func addSubtitles() -> Self {
        
        // Get subtitle view
        getContainer()
        
        // Create label
        addSubtitleLabel()
        
        // Notifications
        registerNotifications()
        
        return self
        
    }
    
    func open(file filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        
        let contents = try! String(contentsOf: filePath, encoding: encoding)
        show(subtitles: contents)
        
    }
    
    func show(subtitles string: String) {
        
        // Parse
        parsedPayload = parseSubRip(string)
        
        // Timer
        timer = Timer.schedule(repeatInterval: 0.5) { (timer) -> Void in self.searchSubtitles() }
        
    }
    
    //MARK:- Private methods
    fileprivate func getContainer() {
        
        for a in view.subviews {
            for b in a.subviews {
                for c in b.subviews {
                    if c.tag == 1006 {
                        subtitleContainer = c
                    }
                }
            }
        }
        
    }
    
    fileprivate func addSubtitleLabel() {
        
        guard let _ = subtitleLabel else {
            
            // Label
            subtitleLabel = UILabel()
            subtitleLabel?.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel?.backgroundColor = UIColor.clear
            subtitleLabel?.textAlignment = .center
            subtitleLabel?.numberOfLines = 0
            subtitleLabel?.font = UIFont.boldSystemFont(ofSize: UI_USER_INTERFACE_IDIOM() == .pad ? 40.0 : 22.0)
            subtitleLabel?.textColor = UIColor.white
            subtitleLabel?.numberOfLines = 0;
            subtitleLabel?.layer.shadowColor = UIColor.black.cgColor
            subtitleLabel?.layer.shadowOffset = CGSize(width: 1.0, height: 1.0);
            subtitleLabel?.layer.shadowOpacity = 0.9;
            subtitleLabel?.layer.shadowRadius = 1.0;
            subtitleLabel?.layer.shouldRasterize = true;
            subtitleLabel?.layer.rasterizationScale = UIScreen.main.scale
            subtitleLabel?.lineBreakMode = .byWordWrapping
            subtitleContainer?.addSubview(subtitleLabel!)
            
            // Position
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[l]-(20)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["l" : subtitleLabel!])
            subtitleContainer?.addConstraints(constraints)
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[l]-(30)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["l" : subtitleLabel!])
            subtitleContainer?.addConstraints(constraints)
            subtitleLabelHeightConstraint = NSLayoutConstraint(item: subtitleLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 30.0)
            subtitleContainer?.addConstraint(subtitleLabelHeightConstraint!)
            
            return
            
        }
        
    }
    
    fileprivate func registerNotifications() {
        
        // Finished
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
            object: self,
            queue: OperationQueue.main) { (notification) -> Void in
                
                self.subtitleLabel?.isHidden = true
                self.timer?.invalidate()
                
        }
        
        // Change
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.MPMoviePlayerPlaybackStateDidChange,
            object: self,
            queue: OperationQueue.main) { (notification) -> Void in
                
                switch self.playbackState {
                    
                case .playing:

                    // Start timer
                    self.timer = Timer.schedule(repeatInterval: 0.5) { (timer) -> Void in self.searchSubtitles() }

                    break
                    
                default:
                    
                    // Stop timer
                    self.timer?.invalidate()
                    
                    break
                    
                }
                
        }
        
    }
    
    fileprivate func parseSubRip(_ payload: String) -> NSDictionary? {
        
        do {
            
            // Prepare payload
            var payload = payload.replacingOccurrences(of: "\n\r\n", with: "\n\n")
            payload = payload.replacingOccurrences(of: "\n\n\n", with: "\n\n")
            
            // Parsed dict
            let parsed = NSMutableDictionary()
            
            // Get groups
            let regexStr = "(?m)(^[0-9]+)([\\s\\S]*?)(?=\n\n)"
            let regex = try NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
            let matches = regex.matches(in: payload, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, payload.characters.count))
            for m in matches {
                
                let group = (payload as NSString).substring(with: m.range)
                
                // Get index
                var regex = try NSRegularExpression(pattern: "^[0-9]+", options: .caseInsensitive)
                var match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.characters.count))
                guard let i = match.first else {
                    continue
                }
                let index = (group as NSString).substring(with: i.range)
                
                // Get "from" & "to" time
                regex = try NSRegularExpression(pattern: "\\d{1,2}:\\d{1,2}:\\d{1,2},\\d{1,3}", options: .caseInsensitive)
                match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.characters.count))
                guard match.count == 2 else {
                    continue
                }
                guard let from = match.first, let to = match.last else {
                    continue
                }
                
                var h: TimeInterval = 0.0, m: TimeInterval = 0.0, s: TimeInterval = 0.0, c: TimeInterval = 0.0
                
                let fromStr = (group as NSString).substring(with: from.range)
                var scanner = Scanner(string: fromStr)
                scanner.scanDouble(&h)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&m)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&s)
                scanner.scanString(",", into: nil)
                scanner.scanDouble(&c)
                let fromTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)
                
                let toStr = (group as NSString).substring(with: to.range)
                scanner = Scanner(string: toStr)
                scanner.scanDouble(&h)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&m)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&s)
                scanner.scanString(",", into: nil)
                scanner.scanDouble(&c)
                let toTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)
                
                // Get text & check if empty
                let range = NSMakeRange(0, to.range.location + to.range.length + 1)
                guard (group as NSString).length - range.length > 0 else {
                    continue
                }
                let text = (group as NSString).replacingCharacters(in: range, with: "")
                
                // Create final object
                let final = NSMutableDictionary()
                final["from"] = fromTime
                final["to"] = toTime
                final["text"] = text
                parsed[index] = final
                
            }
            
            return parsed
            
        } catch {
            
            return nil
            
        }
        
    }
    
    fileprivate func searchSubtitles() {
        
        if playbackState == .playing {
            
            let predicate = NSPredicate(format: "(%f >= %K) AND (%f <= %K)", currentPlaybackTime, "from", currentPlaybackTime, "to")
            
            guard let values = parsedPayload?.allValues else {
                return
            }
            guard let result = (values as NSArray).filtered(using: predicate).first as? NSDictionary else {
                subtitleLabel?.text = ""
                return
            }
            guard let label = subtitleLabel else {
                return
            }
            
            // Set text
            label.text = (result["text"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            // Adjust size
            let rect = (label.text! as NSString).boundingRect(with: CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : label.font!], context: nil)
            subtitleLabelHeightConstraint?.constant = rect.size.height + 5.0
            subtitleContainer?.layoutIfNeeded()
            
        }
        
    }
    
}

// Others
public extension Timer {
    
    class func schedule(repeatInterval interval: TimeInterval, handler: ((Timer?) -> Void)!) -> Timer! {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, .commonModes)
        return timer
    }
    
}
