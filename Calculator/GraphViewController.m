//
//  GraphViewController.m
//  Graph
//
//  Created by timnit gebru on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, strong) UITapGestureRecognizer *tripleTapRecognizer;
@end

@implementation GraphViewController
@synthesize yValue = _yValue;
@synthesize xValue = _xValue;
@synthesize graphView=_graphView;
@synthesize controllerDataSource= _controllerDataSource;
@synthesize tripleTapRecognizer = _tripleTapRecognizer;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem; //implementation of SplitViewBarButtonItemPresenter protocol
//@synthesize toolbar = _toolbar; //to put splitViewBarButton in 


- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem){
        //NSMutableArray *toolbarItems = [self.toolbar.items mutableclopy];
        //if (_splitViewBarButtonItem)[toolbarItems removeObject:_splitViewBarButtonItem];
        //if (splitViewBarButtonItem)[toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
       // self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

-(double)yValueForGraphView:(GraphView *)sender:(double)atXValue
{
    return [self.controllerDataSource yValueForGraphViewController:self :atXValue];
}

-(void)setYValue:(double)yValue
{
    _yValue = 0.0;
    _xValue = 0.0;
    [self.graphView setNeedsDisplay]; //any time we get new value, redraw our view
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    
    //enable pinch gestures in the GraphView using its pinch: handler
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    
    //recognize a pan gesutre and modify our origin
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    
    //recognize a triple tap gesutre and modify our origin
    self.tripleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tripleTap:)];
    self.tripleTapRecognizer.numberOfTapsRequired = 3;
    self.tripleTapRecognizer.numberOfTouchesRequired=1;
    
    [self.graphView addGestureRecognizer:self.tripleTapRecognizer];
    self.graphView.dataSource = self;
    
}

/*
- (void) handleGraphGesture:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || 
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self.graphView];
        self.yValue -= translation.y/2; //will update GraphView via graph
        self.xValue -= translation.x/2;
        [gesture setTranslation:CGPointZero inView:self.graphView];
    }
}
 */

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES; //support all orientations
}

@end
