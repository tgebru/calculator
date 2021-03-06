//
//  GraphView.m
//  Graph
//
//  Created by timnit gebru on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@interface GraphView()
@property (nonatomic, strong) AxesDrawer *axesDrawer;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@end


@implementation GraphView
@synthesize  dataSource = _dataSource;
@synthesize scale = _scale;
@synthesize origin= _origin;
@synthesize axesDrawer = _axesDrawer;


#define DEFAULT_SCALE 10
#define SCALE_KEY  @"scale"
#define ORIGIN_KEY @"origin"


- (CGFloat)scale
{
    if(!_scale){
        //get scale from NSUserDefaults
        NSArray *scaleArrayStoredByUser = (NSArray *) [[NSUserDefaults standardUserDefaults] objectForKey:SCALE_KEY];
        CGFloat scaleStoredByUser = [(NSNumber *)[scaleArrayStoredByUser objectAtIndex:0] floatValue]; 
        if (scaleStoredByUser)return scaleStoredByUser;
        return DEFAULT_SCALE; //don't allow zero scale
    }else {
        return _scale;
    }
}

- (void) setScale:(CGFloat)scale
{
    if (scale !=_scale) {
        _scale = scale;
        [self setNeedsDisplay]; //any time our scale changes, call for redraw
    }
}


- (CGPoint)origin
{
    if (!_origin.x && !_origin.y){
        //get origin from NSUserDefaults
        NSArray *originCoordinatesStoredByUser = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:ORIGIN_KEY]; 
        CGFloat origin_x = [(NSNumber *)[originCoordinatesStoredByUser objectAtIndex:0]floatValue];
        CGFloat origin_y = [(NSNumber *)[originCoordinatesStoredByUser objectAtIndex:1]floatValue]; 
        if (origin_x && origin_y){
            CGPoint originStoredByUser = CGPointMake(origin_x, origin_y);
            return originStoredByUser;
        }
    }
    return _origin;
}

- (void) setOrigin:(CGPoint) origin
{
    if (_origin.x != origin.x && _origin.y != origin.y){
        _origin.x = origin.x;
        _origin.y = origin.y;
        [self setNeedsDisplay]; //any time our origin changes, call for redraw
    }
    
    
}

- (void) saveToNSDefaults:(id)value :(NSString *)key
{
    id valueConvertedToObject = value;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([value isKindOfClass:[NSValue class]]){
        CGPoint origin = [(NSValue *)value CGPointValue];
        NSNumber *origin_x = [NSNumber numberWithFloat:origin.x];
        NSNumber *origin_y = [NSNumber numberWithFloat:origin.y];
        NSArray *arrayWithOriginCoordinates = [NSArray arrayWithObjects:origin_x,origin_y, nil];
        valueConvertedToObject = arrayWithOriginCoordinates;
    }
    
    [defaults setObject:valueConvertedToObject forKey:key];
    [defaults synchronize];
    
    //NSLog (@"done saving to defaults");
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *=gesture.scale; //adjust our scale
        gesture.scale = 1; //reset gesture's scale to 1 (so future changes are incremental--not cumulative
        
        
        //save change in NSUser Defaults
        NSNumber * scaleConvertedToObject = [NSNumber numberWithFloat:self.scale];
        [self saveToNSDefaults:scaleConvertedToObject :@"scale"];

    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        CGPoint my_origin = self.origin;
        
        my_origin.x += translation.x/2; //will update GraphView via graph
        my_origin.y += translation.y/2;
        
        self.origin = my_origin;

        [gesture setTranslation:CGPointZero inView:self]; 
        
        //save change in NSUser Defaults
        NSValue *originConvertedToObject = [NSValue valueWithCGPoint:self.origin];
        [self saveToNSDefaults:originConvertedToObject:@"origin"];
    }
}

- (void)tripleTap:(UITapGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        
        CGPoint translation = [gesture locationInView:self];
        CGPoint my_origin = self.origin;
                
        my_origin.x = translation.x; //will update GraphView via graph
        my_origin.y = translation.y;
        self.origin = my_origin;
                
        //save change in NSUser Defaults
        NSValue *originConvertedToObject = [NSValue valueWithCGPoint:self.origin];
        [self saveToNSDefaults:originConvertedToObject:@"origin"];
    }
}

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw; //if our bounds change, redraw ourselves
}

- (void)awakeFromNib
{
    [self setup]; //get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; //get initialized if someone uses alloc/initWithFrame to create us
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{    
    //Draw the axes if they haven't been drawn yet
    if (!_origin.x  && !_origin.y){
        CGPoint origin;
        origin.x = self.bounds.size.width/2;
        origin.y = self.bounds.size.height/2;
        self.origin = origin;
    }
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat size = self.bounds.size.width /2;
    if (self.bounds.size.height < self.bounds.size.width) size = self.bounds.size.height/2;
   // self.scale = 10;
    size *=self.scale; //scale is percentage of full view size
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blackColor] setStroke];
    
    //Draw the Axes first
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale: self.scale*self.contentScaleFactor];
    

    //Iterate over pixels horizontally
    //get Y value for each x value and draw a line connecting the dots
  
    CGPoint lastPoint;
    CGPoint line;
    //lastPoint.x = self.bounds.origin.x;
    //line.y = [self.dataSource yValueForGraphView:self :line.x-self.bounds.size.width/2]+self.bounds.size.height/2;
   
    //Iterate horizontally, get the Y value of each X and graph it
    for (int x=self.bounds.origin.x; x<self.contentScaleFactor* self.bounds.origin.x+self.bounds.size.width; x++){
        line.x = x;
        //Get Y value from datasource and convert to display scale
        line.y = self.origin.y-(self.scale*[self.dataSource yValueForGraphView:self :(1/self.scale)*(line.x-self.origin.x)]);
        //NSLog(@"x=%@, y=%@", [NSString stringWithFormat:@"%f", line.x], [NSString stringWithFormat:@"%f", line.y]);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(context, line.x, line.y);
        CGContextStrokePath(context);
        lastPoint.x = line.x;
        lastPoint.y = line.y;
    }
    
}

@end
