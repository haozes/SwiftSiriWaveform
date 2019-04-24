//
//  WaveViewController.swift
//  WaveformPlayground
//
//  Created by haozes on 2019/4/23.
//  Copyright © 2019 Dejoe John. All rights reserved.
//

import UIKit
import AVKit


class WaveViewController: UIViewController {

    @IBOutlet var imgView: UIImageView!
    
    private var drawerProxy:WavefromDrawerProxy?
    var recorder:AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawerProxy = WavefromDrawerProxy(image: imgView)
        setupRecorder()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Recorder Setup Begin
    @objc func setupRecorder() {
        if(checkMicPermission()) {
            startRecording()
        } else {
            print("permission denied")
        }
    }
    
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        let recorderSettings = [AVSampleRateKey: NSNumber(value:44100.0),
                                AVFormatIDKey: NSNumber(value:kAudioFormatAppleLossless),
                                AVNumberOfChannelsKey: NSNumber(value: 2),
                                AVEncoderAudioQualityKey: NSNumber(value: Int8(AVAudioQuality.min.rawValue))]
        let url:URL = URL(fileURLWithPath:"/dev/null");
        do {
            try recordingSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)))
            try recordingSession.setActive(true)
            self.recorder = try AVAudioRecorder.init(url: url, settings: recorderSettings as [String : Any])
            let displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(ViewController.updateMeters))
            displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
            self.recorder.prepareToRecord()
            self.recorder.isMeteringEnabled = true
            self.recorder.record()
            print("recorder enabled")
        } catch {
            print("recorder init failed")
        }
    }
    
    
    @objc func updateMeters() {
        var normalizedValue: Float
        recorder.updateMeters()
        normalizedValue = _normalizedPowerLevelFromDecibels(decibels: recorder.averagePower(forChannel: 0))
        self.drawerProxy?.updateWithLevel(level: normalizedValue)
    }
    
    
    func _normalizedPowerLevelFromDecibels(decibels:Float) -> Float {
        if (decibels < -60.0 || decibels == 0.0) {
            return 0.0;
        }
        
        let a = (pow(10.0, 0.05 * decibels) - pow(10.0, 0.05 * -60.0))
        let b = Float(1.0 / (1.0 - pow(10.0, 0.05 * -60.0)))
        return pow( a * b, 1.0 / 2.0);
        
    }
    
    func checkMicPermission() -> Bool {
        var permissionCheck: Bool = false
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            permissionCheck = true
        case AVAudioSessionRecordPermission.denied:
            permissionCheck = false
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    permissionCheck = true
                } else {
                    permissionCheck = false
                }
            })
        default:
            break
        }
        
        return permissionCheck
    }
    //Recorder Setup End
    
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
