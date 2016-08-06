
# MLVAlertKit
[![Platform](https://img.shields.io/badge/platform-iOS7%2B-lightgrey.svg)]()
[![CocoaPods](https://img.shields.io/badge/pod-1.1.0-377ADE.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](http://img.shields.io/badge/license-MIT-black.svg)](http://opensource.org/licenses/MIT)
[![Twitter](https://img.shields.io/badge/twitter-@melvyndev-blue.svg?style=flat)](http://twitter.com/melvyndev)

MLVAlertKit is a customizable alert and action sheet UI framework like UIAlertController,but we changed present and dismiss animator to raise user experience , also you can customize text attributes for yourself. 

[![MLVAlertKit](https://raw.github.com/melvyndev/Assets/master/MLVAlertKit.gif)]()

## Requirements
| MLVAlertKit Version | Minimum iOS Target  | Descriptions            |
|:-------------------:|:-------------------:|:-----------------------:|
| 1.0.0               | iOS 8               |                         |
| 1.1.0               | iOS 7               | add UITextField support |

## Installation
MLVAlertKit can be added to a project using CocoaPods、Cathage, One may also use source files included in the project.

###CocoaPods
[CocoaPods](http://cocoapods.org) is the recommended way to add MLVAlertKit to your project.

1. Add a pod entry for MLVAlertKit to your Podfile `pod 'MLVAlertKit', '~> 1.1.0'` or `pod 'MLVAlertKit'`
2. Install the pod(s) by running `pod install` or update by running `pod update`
3. Include MLVAlertKit wherever you need it with `#import <MLVAlertKit/MLVAlertKit.h>`.

###Carthage
1. Add MLVAlertKit to your Cartfile. e.g., `github "melvyndev/MLVAlertKit" ~> 1.1.0`
2. Run `carthage update`
3. Follow the rest of the [standard Carthage installation instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add MLVAlertKit to your project.

###Source files
Alternatively you can directly add the source files to your project.

1. Download the [latest code version](https://github.com/Melvyndev/MLVAlertKit/archive/master.zip) or add the repository as a git submodule to your git-tracked project.
2. Open your project in Xcode, then drag and drop `MLVAlertKit.h` `MLVAlertController.h` `MLVAlertController.m` `MLVAlertAnimator.h` `MLVAlertAnimator.m` onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project.
3. Include MLVAlertKit wherever you need it with `#import "MLVAlertKit.h"`.

## Usage
You can present the alert from any UIViewController like UIAlertController.
```objective-c
MLVAlertController *alert = [MLVAlertController alertControllerWithTitle:@"Remind !!" message:@"Support is on Github" preferredStyle:MLVAlertControllerStyleAlert];
MLVAlertAction *cancel = [MLVAlertAction actionWithTitle:@"Cancel" style:MLVAlertActionStyleCancel handler:^(MLVAlertAction * _Nonnull action) {

}];
[alert addAction:cancel];
[self presentViewController:alert animated:YES completion:NULL];
```

Add UITextFiels using the reference that:
```objective-c
- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;

```

If you need to configure the attributes you can do this by using the MLVAlertController reference that:
```objective-c
+ (instancetype)alertControllerWithAttributedTitle:(nullable NSAttributedString *)title message:(nullable NSAttributedString *)message preferredStyle:(MLVAlertControllerStyle)preferredStyle;
+ (instancetype)actionWithAttributedTitle:(NSAttributedString *)title style:(MLVAlertActionStyle)style handler:(void (^ __nullable)(MLVAlertAction *action))handler;
```

For more examples, download [MLVAlertKit](https://github.com/Melvyndev/MLVAlertKit/archive/master.zip) and try out the iPhone example app

## License
MLVAlertKit is released under the MIT license. See LICENSE for details.
