# SimpleLayout

SimpleLayout helps you to using auto layout very easily

[![CI Status](http://img.shields.io/travis/pisces/SimpleLayout.svg?style=flat)](https://travis-ci.org/pisces/SimpleLayout)
[![Version](https://img.shields.io/cocoapods/v/SimpleLayout-Swift.svg?style=flat)](http://cocoapods.org/pods/SimpleLayout-Swift)
[![License](https://img.shields.io/cocoapods/l/SimpleLayout-Swift.svg?style=flat)](http://cocoapods.org/pods/SimpleLayout-Swift)
[![Platform](https://img.shields.io/cocoapods/p/SimpleLayout-Swift.svg?style=flat)](http://cocoapods.org/pods/SimpleLayout-Swift)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Difference in code

#### Using auto layout with pure iOS SDK
```Swift
let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: -10)
let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 10)
let width = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
let height = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
            
view.addConstraints([width, height])
view.layoutIfNeeded()
self.addConstraints([top, trailing])
self.layoutIfNeeded()
```

#### Using auto layout with SimpleLayout
```Swift
view.layout
    .top(-10)
    .trailing(10)
    .width(fixed: 30)
    .height(fixed: 30)
```

### To implement auto layout using the fill method
<p valign="top">
<img src="Screenshot/sh_01.png" width="320"/>
</p>

```Swift
import UIKit
import SimpleLayout

class FillExampleViewController: UIViewController {
    
    private lazy var subview: UIView = {
        let label = UILabel()
        label.text = "subview"
        label.textColor = .white
        
        let subview = UIView()
        subview.backgroundColor = .red
        
        subview.addSubview(label)
        label.layout
            .leading()
            .top()
            .width(fixed: 0, relation: .greaterThanOrEqual)
            .height(fixed: 0, relation: .greaterThanOrEqual)
        return subview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .bottom
        
        let label = UILabel()
        label.text = "view"
        
        self.view.addSubview(label)
        self.view.addSubview(subview)

        label.layout
            .leading()
            .top()
            .width(fixed: 0, relation: .greaterThanOrEqual)
            .height(fixed: 0, relation: .greaterThanOrEqual)
        subview.layout.fill(leading: 30, top: 30, trailing: -30, bottom: -30)
    }
}
```

### To implement auto layout using the property chain
<p valign="top">
<img src="Screenshot/sh_02.png" width="320"/>
</p>

```Swift
import UIKit
import SimpleLayout

class ChainExampleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .bottom
        
        let subview1 = label(backgroundColor: .red, text: "subview1")
        let subview2 = label(backgroundColor: .purple, text: "subview2")
        let subview3 = label(backgroundColor: .blue, text: "subview3")
        
        self.view.addSubview(subview1)
        self.view.addSubview(subview2)
        self.view.addSubview(subview3)
        
        subview1.layout
            .leading()
            .top()
            .width()
            .height(fixed: 150)
        subview2.layout
            .leading(by: subview1)
            .top(by: subview1, attribute: .bottom)
            .width(fixed: self.view.width/2)
            .bottom()
        subview3.layout
            .leading(by: subview2, attribute: .trailing)
            .top(by: subview2)
            .trailing()
            .bottom()
    }
    
    private func label(backgroundColor: UIColor, text: String) -> UILabel {
        let label = UILabel()
        label.backgroundColor = backgroundColor
        label.text = text
        label.textAlignment = .center
        label.textColor = .white
        return label
    }
}
```

## Requirements

iOS SDK 8.0 equal or higher

## Installation

SimpleLayout is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SimpleLayout-Swift"
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Alamofire into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pisces/SimpleLayout" ~> 1.0.0
```

Run `carthage update` to build the framework and drag the built `SimpleLayout.framework` into your Xcode project.

## Author

Steve Kim, hh963103@gmail.com

## License

SimpleLayout is available under the MIT license. See the LICENSE file for more info.
