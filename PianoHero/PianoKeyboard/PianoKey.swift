//
//  PianoKey.swift
//  PianoKeyboard
//
//  Created by Jeff Holtzkener on 8/23/16.
//  Copyright © 2016 Jeff Holtzkener. All rights reserved.
//
import UIKit

class PianoKey: UIButton {
    enum KeyType {
        case whiteKey, blackKey
    }
    
    let margin: CGFloat = 0.0
    let normalColor: UIColor!
    let keyType: KeyType!
    let midiNoteNumber: UInt8!
    var pressedColor = "#FFCB17".hexColor
    
    lazy var lblTitle: UILabel = {
        let lbl = UILabel.init()
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 10)
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.minimumScaleFactor = 0.5
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
        
    enum KeyStates {
        case notPressed, pressed
    }
    
    var keyState: KeyStates = .notPressed
    
    init(frame: CGRect, midiNoteNumber: UInt8, type: KeyType) {
        self.keyType = type
        self.normalColor = type == .whiteKey ? .white : .black
        self.midiNoteNumber = midiNoteNumber
        super.init(frame: frame)
        isUserInteractionEnabled = false
        
        lblTitle.textColor = type == .whiteKey ? .black : .white
        addSubview(lblTitle)
        lblTitle.frame = CGRect(x: 4, y: 100, width: 10, height: 80)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // will never call this
        self.normalColor = .black
        self.keyType = .whiteKey
        self.midiNoteNumber = 60
        super.init(coder: aDecoder)
    }
    
    func getPathAtMargin() -> UIBezierPath {
        // set margin property if wanted
        let cornerRadius =  CGSize(width: self.bounds.width / 5.0, height: self.bounds.width / 5.0)
        let marginRect = CGRect(x: margin,
                                y: margin,
                                width: self.bounds.width - (margin * 2.0),
                                height: self.bounds.height - (margin * 2.0))
        let path = UIBezierPath(roundedRect: marginRect,
                                byRoundingCorners: [.bottomLeft, .bottomRight],
                                cornerRadii: cornerRadius)
        path.lineWidth = 2.0
        
        return path
    }
    
    override func draw(_ rect: CGRect) {
        let path = getPathAtMargin()
        switch keyState {
        case .notPressed:
            normalColor.setFill()
        case .pressed:
//            UIColor.lightGray.setFill()
            pressedColor.setFill()
        }
        UIColor.black.setStroke()
        path.fill()
        path.stroke()
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    // MARK: - Respond to key presses
    func pressed(_ color: UIColor = "#FFCB17".hexColor) -> Bool {
        if keyState != .pressed {
            keyState = .pressed
            pressedColor = color
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
            return true
        } else {
            return false
        }
    }
    
    func released() -> Bool {
        if keyState != .notPressed {
            keyState = .notPressed
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
            return true
        } else {
            return false
        }
    }
}
