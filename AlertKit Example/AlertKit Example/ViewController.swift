//
//  AlertAction.swift
//
//  Copyright (c) 2022 Junfeng Zhang All rights reserved.
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

import UIKit
import AlertKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let textLabelText = tableView.cellForRow(at: indexPath)!.textLabel!.text!
        let useDefaultStyle = textLabelText.hasPrefix("Default")
        
        let preferredStyle: AlertController.Style = textLabelText.hasSuffix("Alert") ? .alert : .actionSheet
       
        let alert: AlertController
        if useDefaultStyle {
            alert = .init(title: "Remind !!", message: "Support is on Github", preferredStyle: preferredStyle)
        } else {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font : UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.systemOrange,
                .paragraphStyle : paragraphStyle
            ]
            
            let title = NSAttributedString(string: "Remind !!", attributes: attributes)
            let message = NSAttributedString(string: "Support is on Github", attributes: attributes)
            alert = .init(attributedTitle: title, message: message, preferredStyle: preferredStyle)
            
            let description = NSMutableAttributedString(string: "We’re here to provide tips, tricks, and helpful information when you need it most.", attributes: attributes)
            description.setAttributes([.font : UIFont.systemFont(ofSize: 30)], range: NSMakeRange(5, 5))
            description.setAttributes([.foregroundColor : UIColor.systemRed], range: NSMakeRange(13, 8))
            
            let action = AlertAction(attributedTitle: description, style: .default, handler: nil)
            alert.addAction(action)
        }
        
        let confirm = AlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(confirm)

        let destructive = AlertAction(title: "Destructive", style: .destructive, handler: nil)
        alert.addAction(destructive)

        let cancel = AlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        if alert.preferredStyle == .alert {
            alert.addTextField { textField in
                textField.borderStyle = .roundedRect
            }
        }
        
        self.present(alert, animated: true)    }
}
/*
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
   
   if (alert.preferredStyle == MLVAlertControllerStyleAlert) {
       [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
           textField.borderStyle = UITextBorderStyleRoundedRect;
       }];
   }
   
   [self presentViewController:alert animated:YES completion:NULL];
    */
