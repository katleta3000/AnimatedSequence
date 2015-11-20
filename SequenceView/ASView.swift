//
//  SequenceView.swift
//  SequenceView
//
//  Created by Evgenii Rtishchev on 19/11/15.
//  Copyright © 2015 Evgenii Rtishchev. All rights reserved.
//

import UIKit

class ASView: UIView, ASMemoryControllerDelegate {
    var loop = true // loops animation
    var useCache: Bool = true { // caches images from sequence and reduce CPU usage, but may allocate sufficient memory
        didSet {
            updateUseCache()
        }
    }
    var autoClearCache = true { // automatically clear cache, when received memory warning
        didSet {
            updateAutoClearCache()
        }
    }
    var autoResizeImage = false { // automatically resize image for appropriate screen scale if it's possible
        didSet {
            updateAutoResizeImage()
        }
    }
    var rate: NSTimeInterval = 1/30
    private var currentIndex = 0
    private var totalCount = 0
    private var startIndex = 0
    private var baseString: String!
    private var timer: NSTimer!
    private var imageView: UIImageView!
    private var imageCache: [Int: UIImage]!
    private var memoryController: ASMemoryController!
    
    init(name: String, start: Int, count: Int, frame: CGRect = CGRectZero) {
        super.init(frame: frame)
        startIndex = start
        currentIndex = startIndex
        totalCount = count
        baseString = name
        createImageView(frame)
        updateUseCache()
        updateAutoClearCache()
        updateAutoResizeImage()
    }
    
    func startAnimation() {
        timer = NSTimer(timeInterval: rate, target: self, selector: "tick", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    func clearCache() {
        guard useCache else { return }
        guard imageCache != nil else { return }
        imageCache = [Int: UIImage]()
    }
    
    // MARK: - private
    
    func tick() {
        guard currentIndex < totalCount else {
            guard loop else { return }
            currentIndex = startIndex
            return
        }
        
        render(currentIndex)
        currentIndex++
    }
    
    private func render(i: Int) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { () -> Void in
            let indexString = String(i)
            let end = self.baseString.characters.count
            let start = end - indexString.characters.count
            let name = NSString(string: self.baseString).stringByReplacingCharactersInRange(NSMakeRange(start, indexString.characters.count), withString: indexString)
            if self.useCache && self.imageCache[i] != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageView.image = self.imageCache[i]
                })
            } else if let path = NSBundle.mainBundle().pathForResource(name, ofType: "png"),
                data = NSData(contentsOfFile: path),
                var image = UIImage(data: data) {
                    if self.useCache { self.imageCache[i] = image }
                    if self.autoResizeImage { image = self.resizedImage(image) }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.imageView.image = image
                    })
            }
        }
    }
    
    private func createImageView(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        imageView.backgroundColor = .clearColor()
        imageView.contentMode = .ScaleAspectFit
        self.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    private func updateUseCache() {
        if useCache { imageCache = [Int: UIImage]() }
    }
    
    private func updateAutoClearCache() {
        if autoClearCache {
            memoryController = ASMemoryController()
            memoryController.delegate = self
        }
    }
    
    private func updateAutoResizeImage() {
        
    }
    
    private func resizedImage(image: UIImage) -> UIImage {
        let size = self.bounds.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    // MARK: - ASMemoryControllerDelegate
    
    func didReceiveMemoryWarning() {
        clearCache()
    }
}

protocol ASMemoryControllerDelegate {
    func didReceiveMemoryWarning()
}

class ASMemoryController: UIViewController {
    var delegate: ASMemoryControllerDelegate!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        delegate.didReceiveMemoryWarning()
    }
}
