//
//  GraphViewController.m
//  Graph
//
//  Created by timnit gebru on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) UITapGestureRecognizer *tripleTapRecognizer;
@end

@implementation GraphViewController
@synthesize yValue = _yValue;
@synthesize xValue = _xValue;
@synthesize toolbar = _toolbar;
@synthesize graphView=_graphView;
@synthesize controllerDataSource= _controllerDataSource;
@synthesize tripleTapRecognizer = _tripleTapRecognizer;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem; //implementation of SplitViewBarButtonItemPresenter protocol

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

// viewDidLoad is callled after this view controller has been fully instantiated
//  and its outlets have all been hooked up.

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
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

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES; //support all orientations
}

- (void)viewDidUnload {
    [self setToolbar:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
}
@end
