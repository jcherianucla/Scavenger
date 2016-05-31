//
//  MessageView.swift
//  MemCap
//
//  Created by Jahan Cherian on 5/22/16.
//  Copyright © 2016 Jahan Cherian. All rights reserved.
//

import UIKit

class MessageView: UIView
{
    var view: UIView!
    
    @IBOutlet weak var messageTextField: UITextView!
    
    var delegate: messageProtocol? = nil
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        // MainView!.backgroundColor = lightColor
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    @IBAction func CancelButtonPressed(sender: AnyObject)
    {
        if(delegate != nil)
        {
            self.delegate?.cancelButtonPressed()
        }
    }
    @IBAction func SendButtonPressed(sender: AnyObject)
    {
        if(delegate != nil)
        {
            self.delegate?.sendButtonPressed()
        }
        
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
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "MessageView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
}
