//
//  CircleImageView.swift
//  MemCap
//
//  Created by Jahan Cherian on 4/26/16.
//  Copyright © 2016 Jahan Cherian. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CircleImageView: UIView
{
    let π: CGFloat = CGFloat(M_PI)

    private var imageView: UIImageView!
    //Give users option of changing this
    @IBInspectable var strokeWidth:CGFloat = 2
    @IBInspectable var strokeColor = UIColor.whiteColor()
    
    @IBInspectable var image: UIImage?
        {
        didSet
        {
            if image != nil
            {
                imageView.image = image
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        imageView = UIImageView(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        imageView = UIImageView(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect)
    {
        let centerX = rect.width/2
        let centerY = rect.height/2
        
        let centerPoint = CGPoint(x: centerX, y: centerY)
        let radius = rect.height / 2

        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius*0.9, startAngle: 0, endAngle: 2.0 * π, clockwise: true)
        circlePath.lineWidth = strokeWidth
        strokeColor.setStroke()
        circlePath.stroke()
        
        let mask = CAShapeLayer()
        mask.path = circlePath.CGPath
        imageView.frame = CGRectMake(0, 0, rect.width, rect.height)
        imageView.layer.mask = mask
        self.addSubview(imageView)
    }
    
    func setSize(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)
    {
        self.frame = CGRectMake(x, y, width, height)
    }
    
    func setThumbnailImage(image: UIImage?)
    {
        if let thmbImage = image{
            imageView.image = thmbImage
        }
    }
}