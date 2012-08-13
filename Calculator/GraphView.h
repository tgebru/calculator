//
//  GraphView.h
//  Graph
//
//  Created by timnit gebru on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GraphView;

@protocol GraphViewDataSource
-(double) yValueForGraphView: (GraphView*)sender: (double)atXValue;
@end

@interface GraphView : UIView

//@property (nonatomic) CGFloat scale;
//@property (nonatomic) CGPoint origin;

-(void)pinch:(UIPinchGestureRecognizer *)gesture;
-(void)pan: (UIPanGestureRecognizer *)gesture;

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
