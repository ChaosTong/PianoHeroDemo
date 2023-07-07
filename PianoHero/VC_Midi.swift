//
//  VC_Midi.swift
//  PianoHero
//
//  Created by ChaosTong on 2023/7/7.
//

import Foundation
import UIKit

class VC_Midi: UIViewController {
    
    lazy var keyBoard: Keyboard = {
        let v = Keyboard(frame: CGRect(x: 0, y: ScreenH-200, width: ScreenW, height: 200))
        v.delegate = self
        v.octave = 1
        v.numWhiteKeys = 52
        v.lowestWhiteNote = .A
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView(frame: CGRect(x: 0, y: 0, width: ScreenW, height: ScreenH-200))
        v.delegate = self
        return v
    }()
    
    var midiPath = ""
    private let audioEngine = AudioEngine()
    private let timerQueue = DispatchQueue(label: "com.easyulife.PianoHero")
    var heartbeatTimer: DispatchSourceTimer?
    var index: [Int] = []
    let midi = MidiData()
    var notes: [[MidiNote]] = []
    var startTime = Date().addingTimeInterval(3600)
    var offsetTime: Double = 0
    var max: Double = 0
    let w = 200.0
    var pauseFlag = false
    
    let colors = ["#763EE8".hexColor, "#E86D3E".hexColor]
    
    var animator: UIViewPropertyAnimator? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initProperties()
        initUI()
    }
    
    func initProperties() {
        let data = NSData(contentsOfFile: midiPath)! as Data
        midi.load(data: data)
        audioEngine.start()
        
        let H = scrollView.frame.height
        
        notes = midi.noteTracks.compactMap({ $0.notes })
        for track in midi.noteTracks {
            for note in track.notes {
                if note.timeStamp.inSeconds + note.duration.inSeconds > max {
                    max = note.timeStamp.inSeconds + note.duration.inSeconds
                }
            }
        }

        scrollView.contentSize = CGSize(width: ScreenW, height: max*w+H)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for (i, track) in self.midi.noteTracks.enumerated() {
                let color = self.colors.get(i) ?? Color.white
                for note in track.notes {
                    let keyFrame = (self.keyBoard.pitchToKeyDict[note.note]!).frame
                    let brick = UIView(frame: CGRect(x: keyFrame.origin.x, y: (self.max - note.timeStamp.inSeconds - note.duration.inSeconds)*self.w + H, width: keyFrame.width, height: note.duration.inSeconds*self.w))
                    brick.layer.masksToBounds = true
                    brick.layer.cornerRadius = 5
                    brick.backgroundColor = color
                    self.scrollView.addSubview(brick)
                    
                    if note.timeStamp.inTicks.value % (self.midi.ticksPerBeat.value/8*3) == 0 {
                        let y = (self.max - note.timeStamp.inSeconds)*self.w + H
                        let line = UIView(frame: CGRect(x: 0, y: y, width: ScreenW, height: 1))
                        line.backgroundColor = .lightGray
                        self.scrollView.addSubview(line)
                    }
                }
            }
            self.scrollView.contentOffset = CGPoint(x: 0, y: self.max*self.w)
        }
    }
    
    func initUI() {        
        view.backgroundColor = .black
        view.addSubview(keyBoard)
        view.addSubview(scrollView)
        
        let btn = UIButton.init(frame: CGRect(x: ScreenW-20-80, y: 100, width: 80, height: 80))
        btn.tag = 2000
        btn.setTitle("Play", for: .normal)
        btn.setTitle("Pause", for: .selected)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    @objc func btnAction(_ sender: UIButton) {
        if sender.tag == 2000 {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                pauseFlag = false
                let off = scrollView.contentOffset.y
                offsetTime = (max*w - scrollView.contentOffset.y)*max/(max*w)
                start(max: max*off/(max*w))
            } else {
                pauseFlag = true
                animator?.stopAnimation(true)
            }
        }
    }
    
    func start(max: Double) {
        index = Array.init(repeating: 0, count: notes.count)
        startTime = Date()
        
        heartbeatTimer?.cancel()
        heartbeatTimer = nil
        heartbeatTimer = DispatchSource.makeTimerSource(flags: [], queue: timerQueue)
        if let heartbeatTimer = heartbeatTimer {
            heartbeatTimer.schedule(deadline: .now(), repeating: .milliseconds(1))
            heartbeatTimer.setEventHandler { [weak self] in
                self?.loop()
            }
            heartbeatTimer.resume()
        }
        
        animator = UIViewPropertyAnimator(duration: max, curve: .linear) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
        animator?.startAnimation()
    }
    
    @objc func loop() {
        if pauseFlag {
            return
        }
        let gapTime = Date().timeIntervalSince(startTime) + offsetTime
        
        for i in 0..<notes.count {
            if let note = notes[i].get(index[i]) {
                if gapTime > note.timeStamp.inSeconds {
                    let _ = self.keyBoard.pitchToKeyDict[note.note]?.pressed(self.colors.get(i) ?? UIColor.white)
                    audioEngine.sampler.startNote(note.note, withVelocity: note.velocity, onChannel: note.channel)
                    DispatchQueue.main.asyncAfter(deadline: .now() + note.duration.inSeconds) {
                        let _ = self.keyBoard.pitchToKeyDict[note.note]?.released()
                        self.audioEngine.sampler.stopNote(note.note, onChannel: note.channel)
                    }
                    index[i] += 1
                }
            }
        }
    }
}

extension VC_Midi: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offset = scrollView.contentOffset
    }
}

extension VC_Midi: PianoDelegate {
    func noteOn(note: UInt8) {
        audioEngine.sampler.startNote(note, withVelocity: 64, onChannel: 0)
    }
    func noteOff(note: UInt8) {
        audioEngine.sampler.stopNote(note, onChannel: 0)
    }
}
