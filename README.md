
# AlertKit
[![Platform](https://img.shields.io/badge/platform-iOS7%2B-lightgrey.svg)]()
[![CocoaPods](https://img.shields.io/badge/pod-1.1.0-377ADE.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](http://img.shields.io/badge/license-MIT-black.svg)](http://opensource.org/licenses/MIT)
[![Twitter](https://img.shields.io/badge/twitter-@hdtls-blue.svg?style=flat)](http://twitter.com/hdtls)

AlertKit is a customizable alert and action sheet UI framework like UIAlertController,but we changed present and dismiss animator to raise user experience , also you can customize text attributes for yourself. 

<img src="/Screenshots/example.gif" alt="example" />


## Requirements
| AlertKit Version | Minimum iOS Target  | Descriptions            |
|:-------------------:|:-------------------:|:-----------------------:|
| 1.0.0               | iOS 8               |                         |
| 1.1.0               | iOS 7               | add UITextField support |
| 2.0.0               | iOS 11              |                         |

## Installation
AlertKit can be added to a project using CocoaPods、Cathage, One may also use source files included in the project.

### CocoaPods
[CocoaPods](http://cocoapods.org) is the recommended way to add AlertKit to your project.

1. Add a pod entry for AlertKit to your Podfile `pod 'AlertKit', '~> 2.0.0'` or `pod 'AlertKit'`
2. Install the pod(s) by running `pod install` or update by running `pod update`
3. Include AlertKit wherever you need it with `import AlertKit`.

### Source files
Alternatively you can directly add the source files to your project.

1. Download the [latest code version](https://github.com/hdtls/swift-alertkit/archive/main.zip) or add the repository as a git submodule to your git-tracked project.
2. Open your project in Xcode, then drag and drop all source files onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project.

## Usage
You can present the alert from any UIViewController like UIAlertController.
```swift
let alert = AlertController(title: "Remind !!" message: "Support is on Github" preferredStyle:.alert)
let cancel = AlertAction(title: "Cancel" style: .cancel) { action in
    // ...
}
alert.addAction(cancel)
self.present(alert, animated: true, completion:nil)
```

Add UITextFiels using the reference that:
```swift
UIAlarmer.addTextField(withConfiguration:)
```

If you need to configure the attributes you can do this by using the AlertController reference that:
```swift
AlertController(attributedTitle:message:preferredStyle:)
AlertAction(attributedTitle:style:handler:)
```

## License
AlertKit is released under the MIT license. See LICENSE for details.
