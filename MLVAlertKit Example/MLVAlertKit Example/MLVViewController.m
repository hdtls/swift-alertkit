//
//  MLVViewController.m
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

#import "MLVViewController.h"

@import MLVAlertKit;

@interface MLVViewController ()

@end

@implementation MLVViewController


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MLVAlertControllerStyle style = [[tableView cellForRowAtIndexPath:indexPath].textLabel.text hasSuffix:@"Alert"] ? MLVAlertControllerStyleAlert : MLVAlertControllerStyleActionSheet;
    
    MLVAlertController *alert;
    

    if (indexPath.row == 0 || indexPath.row == 1) {
        
        alert = [MLVAlertController alertControllerWithTitle:@"Remind !!" message:@"Support is on Github" preferredStyle:style];
        
    } else {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                     NSForegroundColorAttributeName : UIColor.orangeColor,
                                     NSParagraphStyleAttributeName : paragraphStyle
                                     };
        
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Remind !!" attributes:attributes];
        NSAttributedString *message = [[NSAttributedString alloc] initWithString:@"Support is on Github" attributes:attributes];
        
        alert = [MLVAlertController alertControllerWithAttributedTitle:title message:message preferredStyle:style];
        
        
        NSMutableAttributedString *description = [[NSMutableAttributedString alloc] initWithString:@"We’re here to provide tips, tricks, and helpful information when you need it most." attributes:attributes];
        [description setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:30]} range:NSMakeRange(5, 5)];
        [description setAttributes:@{NSForegroundColorAttributeName : UIColor.redColor} range:NSMakeRange(13, 8)];
        MLVAlertAction *action1 = [MLVAlertAction actionWithAttributedTitle:description style:MLVAlertActionStyleDefault handler:^(MLVAlertAction * _Nonnull action) {
            
            [self.navigationController pushViewController:[[UIViewController alloc] init] animated:YES];
        }];
        
        [alert addAction:action1];
    }
    
    
    MLVAlertAction *ok = [MLVAlertAction actionWithTitle:@"OK" style:MLVAlertActionStyleDefault handler:^(MLVAlertAction * _Nonnull action) {
        NSLog(@"%@", action.title);
    }];
    
    MLVAlertAction *destructive = [MLVAlertAction actionWithTitle:@"Destructive" style:MLVAlertActionStyleDestructive handler:^(MLVAlertAction * _Nonnull action) {
        NSLog(@"%@", action.title);
    }];
    
    MLVAlertAction *cancel = [MLVAlertAction actionWithTitle:@"Cancel" style:MLVAlertActionStyleCancel handler:^(MLVAlertAction * _Nonnull action) {
        NSLog(@"%@", action.title);
    }];
    
    [alert addAction:ok];
    [alert addAction:destructive];
    [alert addAction:cancel];

    
    [self presentViewController:alert animated:YES completion:NULL];
}
@end
