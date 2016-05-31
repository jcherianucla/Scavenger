//
//  UIViewControllerExtension.swift
//  MemCap
//
//  Created by Jahan Cherian on 5/19/16.
//  Copyright © 2016 Jahan Cherian. All rights reserved.
//

import UIKit

extension UIViewController
{
    func displayNSAlert(descriptionString: String, titleString: String)
    {
        JSSAlertView().show(self, title: titleString, text: descriptionString, buttonText: "Dismiss")
    }
}