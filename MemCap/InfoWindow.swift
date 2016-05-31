//
//  InfoWindow.swift
//  MemCap
//
//  Created by Jahan Cherian on 5/26/16.
//  Copyright © 2016 Jahan Cherian. All rights reserved.
//

import UIKit


class InfoWindow: UIView
{

    @IBOutlet weak var profilePicture: UIView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var userMessage: UITextView!
    var view: UIView!
    var circleThumbnail: CircleImageView!
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        // MainView!.backgroundColor = lightColor
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()

    }
    
    required init(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        // 2. call super.init(coder:)
        
        super.init(coder: aDecoder)!
        
        // 3. Setup view from .xib file
        xibSetup()

    }
    
    func xibSetup() {
        view = loadViewFromNib()
        // use bounds not frame or it'll be offset
        view.frame = bounds
        // Make the view stretch with containing view
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        initCircleSetup()
        addSubview(view)
    }
    
    func setAutoResize()
    {
        profilePicture.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        profileName.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        userMessage.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    func initCircleSetup()
    {
        circleThumbnail = CircleImageView()
        circleThumbnail.setSize(0, y: 0, width: self.profilePicture.bounds.width, height: self.profilePicture.bounds.height)
        circleThumbnail.setThumbnailImage(nil)
        circleThumbnail.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.profilePicture.addSubview(circleThumbnail)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "InfoWindow", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
}
