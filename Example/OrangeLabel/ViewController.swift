//
//  ViewController.swift
//  OrangeLabel
//
//  Created by hh963103@gmail.com on 09/04/2017.
//  Copyright (c) 2017 hh963103@gmail.com. All rights reserved.
//

import UIKit
import OrangeLabel
import SimpleLayout_Swift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numbers = UILabelLinkType.custom(pattern: "[0-9]+")
        let label = OrangeLabel()
        label.adjustsFontSizeToFitWidth = true
        label.enabledLinkTypes = [.mention, .hashtag, .url, numbers]
        label.isUserInteractionEnabled = true
        label.font = UIFont(name: "AvenirNext-Bold", size: 60)
        label.minimumScaleFactor = 0.2
        label.lineBackgroundColor = .black
        label.lineBackgroundInset = UIEdgeInsets(top: -5, left: 5, bottom: -5, right: 5)
        label.numberOfLines = 0
        label.text = "@steve Your selfie overed 1000 views 👋👫 @steve Your selfie overed 1000 views @steve Your selfie overed 1000 views @steve #hahaha http://retrica.co Your selfie overed 1000 views @steve Your selfie overed 1000 views @steve Your selfie overed 1000 views www.retrica.co @steve Your selfie overed 1000 views @steve Your selfie overed 1000 views @steve #hahaha Your selfie overed 1000 views @steve Your selfie overed 1000 views 👋👫"
        label.textAlignment = .center
        label.textColor = .white
        
        label.setHighlightedLinkColor(UIColor.white.withAlphaComponent(0.5), type: .mention)
            .setHighlightedLinkColor(UIColor.white.withAlphaComponent(0.5), type: .hashtag)
            .setHighlightedLinkColor(UIColor.white.withAlphaComponent(0.5), type: .url)
            .setHighlightedLinkColor(UIColor.white.withAlphaComponent(0.5), type: numbers)
            .setAttributes([NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
                            NSForegroundColorAttributeName: UIColor(red: 1, green: 185/255, blue: 0, alpha: 1)], type: .mention)
            .setAttributes([NSForegroundColorAttributeName: UIColor(red: 225/255, green: 66/255, blue: 16/255, alpha: 1)], type: .hashtag)
            .setAttributes([NSForegroundColorAttributeName: UIColor(red: 0, green: 204/255, blue: 238/255, alpha: 1)], type: .url)
            .setAttributes([NSForegroundColorAttributeName: UIColor(red: 1, green: 85/255, blue: 0, alpha: 1)], type: numbers)
        
        label.linkTapped { (link) in
            print(link)
        }
        
        view.addSubview(label)
        label.layout
            .leading(24)
            .trailing(-24)
            .top(64)
            .bottom(-24)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

