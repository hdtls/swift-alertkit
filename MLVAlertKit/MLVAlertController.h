//
//  MLVAlertController.h
//
//  Copyright (c) 2016 NEET. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MLVAlertActionStyle) {
    MLVAlertActionStyleDefault = 0,
    MLVAlertActionStyleCancel,
    MLVAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, MLVAlertControllerStyle) {
    MLVAlertControllerStyleActionSheet = 0,
    MLVAlertControllerStyleAlert
};


@interface MLVAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title style:(MLVAlertActionStyle)style handler:(void (^ __nullable)(MLVAlertAction *action))handler;
+ (instancetype)actionWithAttributedTitle:(NSAttributedString *)title style:(MLVAlertActionStyle)style handler:(void (^ __nullable)(MLVAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) MLVAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end


@interface MLVAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(MLVAlertControllerStyle)preferredStyle;
+ (instancetype)alertControllerWithAttributedTitle:(nullable NSAttributedString *)title message:(nullable NSAttributedString *)message preferredStyle:(MLVAlertControllerStyle)preferredStyle;


- (void)addAction:(MLVAlertAction *)action;

@property (nonatomic, readonly) NSArray<MLVAlertAction *> *actions;

@property (nullable, nonatomic, copy, readonly) NSString *message;

@property (nonatomic, readonly) MLVAlertControllerStyle preferredStyle;

@end

NS_ASSUME_NONNULL_END
