//
//  GraphViewController.h
//  Graph
//
//  Created by timnit gebru on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@class GraphViewController;

@protocol GraphViewControllerDataSource
-(double) yValueForGraphViewController: (GraphViewController*)sender: (double)forXValue;
@end

@interface GraphViewController : UIViewController <SplitViewBarButtonItemPresenter>


@property (nonatomic) double yValue; 
@property (nonatomic) double xValue;


@property (nonatomic, weak) IBOutlet id <GraphViewControllerDataSource> controllerDataSource;

@end
