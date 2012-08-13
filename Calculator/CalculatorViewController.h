//
//  CalculatorViewController.h
//  Calculator
//
//  Created by timnit gebru on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController<UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *operandDisplay;
@end
