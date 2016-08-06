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

/**
 *  Enum that specifies the style of the actions
 */
typedef NS_ENUM(NSInteger, MLVAlertActionStyle) {
  
    MLVAlertActionStyleDefault = 0,
   
    MLVAlertActionStyleCancel,
   
    MLVAlertActionStyleDestructive
};

/**
 *  Enum that specifies the style of the alert controller
 */
typedef NS_ENUM(NSInteger, MLVAlertControllerStyle) {
   
    MLVAlertControllerStyleActionSheet = 0,
    
    MLVAlertControllerStyleAlert
};


@interface MLVAlertAction : NSObject

/**
 *  Initialize a action by given it's title, style and handler
 *
 *  @param title   The title that action will display
 *  @param style   The style of the action
 *  @param handler The action handler for action, a block that will be fired when action selected
 *
 *  @return UIAlertAction instance
 */
+ (instancetype)actionWithTitle:(NSString *)title style:(MLVAlertActionStyle)style handler:(void (^ __nullable)(MLVAlertAction *action))handler;

/**
 *  Initialize a action by given it's attributed title, style and handler
 *
 *  @param title   The attributed title that action will display
 *  @param style   The style of the action
 *  @param handler The action handler for action, a block that will be fired when action selected
 *
 *  @return UIAlertAction instance
 */
+ (instancetype)actionWithAttributedTitle:(NSAttributedString *)title style:(MLVAlertActionStyle)style handler:(void (^ __nullable)(MLVAlertAction *action))handler;

/**
 *  Title for action
 */
@property (nonatomic, readonly) NSString *title;

/**
 *  Style for action
 */
@property (nonatomic, readonly) MLVAlertActionStyle style;

/**
 *  A booleam value that determines if the action handler will be fired when action selected
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end



@interface MLVAlertController : UIViewController

/**
 *  Initialize MLVAlertController by given it's title, message and preferred style
 *
 *  @param title          The title that MLVAlertController will display
 *  @param message        The message that MLVAlertController will display
 *  @param preferredStyle See enum 'MLVAlertActionStyle' for more info
 *
 *  @return MLVAlertController instance
 */
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(MLVAlertControllerStyle)preferredStyle;

/**
 *  Initialize MLVAlertController by given it's attributed title, message and preferred style
 *
 *  @param title          The attributed title that MLVAlertController will display
 *  @param message        The attributed message that MLVAlertController will display
 *  @param preferredStyle See enum 'MLVAlertActionStyle' for more info
 *
 *  @return MLVAlertController instance
 */
+ (instancetype)alertControllerWithAttributedTitle:(nullable NSAttributedString *)title message:(nullable NSAttributedString *)message preferredStyle:(MLVAlertControllerStyle)preferredStyle;

/**
 *  Adds a new action to the MLVAlertController instance
 *
 *  @param action The Action that will add to MLVAlertController instance
 */
- (void)addAction:(MLVAlertAction *)action;

/**
 *  The actions added to the MLVAlertController instance
 */
@property (nonatomic, readonly) NSArray<MLVAlertAction *> *actions;

/**
 *  Adds a new TextField to the MLVAlertController instance, MLVAlertControllerStyleAlert only
 *
 *  @param configurationHandler The configuration handler block for textFiled
 */
- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;

/**
 *  The textFields added to the MLVAlertController instance
 */
@property (nullable, nonatomic, readonly) NSArray<UITextField *> *textFields;

/**
 *  The message for MLVAlertController instance
 */
@property (nullable, nonatomic, copy, readonly) NSString *message;

/**
 *  The style for MLVAlertController instance
 */
@property (nonatomic, readonly) MLVAlertControllerStyle preferredStyle;

@end

NS_ASSUME_NONNULL_END
