//
//  CalculatorViewController.m
//  Calculator
//
//  Created by timnit gebru on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController() <GraphViewControllerDataSource>
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL dotHasBeenPressed;
@property (nonatomic) BOOL previousKeyWasOperation;
@property (nonatomic, strong) NSString *previousStackContent;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSMutableDictionary *testVariableValues;
//@property (nonatomic, strong) IBOutlet GraphViewController *graphViewController;

@end

@implementation CalculatorViewController
@synthesize display;
@synthesize operandDisplay=_operandDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber;
@synthesize previousStackContent;
@synthesize previousKeyWasOperation;
@synthesize dotHasBeenPressed = _dotHasBeenPressed;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;
//@synthesize graphViewController= _graphViewController;



//Stuff for iPad split view controller + rotating
- (void)awakeFromNib 
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (id <SplitViewBarButtonItemPresenter>) splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]){
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation):NO;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.title;
    //tell the detail view to put this button up
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void) splitViewController:(UISplitViewController *)svc 
      willShowViewController:(UIViewController *)aViewController 
   invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for all orientations
    return YES;
}


//Normal calculator stuff
- (NSMutableDictionary *) testVariableValues
{
    if (!_testVariableValues){
            
        _testVariableValues = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObject: [NSNumber numberWithDouble: 0]] forKeys:[NSArray arrayWithObject:@"x"]];
    }
    return _testVariableValues;
    
}

- (CalculatorBrain *) brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Display description of program on graph
    //self.graphViewController.controllerDataSource = self;
    [segue.destinationViewController setControllerDataSource:self];
    [segue.destinationViewController setYValue:0.0];
    
}


- (GraphViewController *)splitViewGraphViewController 
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

- (IBAction)graph {
 //Don't segue if its an iPad
    if ([self splitViewGraphViewController]) {
        [self splitViewGraphViewController].controllerDataSource = self;
        [[self splitViewGraphViewController] setYValue:0.0];
    } else {    
        //Segue   
        [self performSegueWithIdentifier:@"Graph" sender:self]; 
    }
  
}

- (double)yValueForGraphViewController:(GraphViewController*)sender: (double)forXValue
{
    [self.testVariableValues setObject:[NSNumber numberWithDouble:forXValue] forKey: @"x"];
    return [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariableValues];
}

- (BOOL) shouldAutoRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = [sender currentTitle];
    NSString *numberToBeDisplayed = digit;
    
    if ([digit isEqualToString:@"."]){
        if (self.dotHasBeenPressed){
            numberToBeDisplayed = @"0";
        }else{
            numberToBeDisplayed = digit;
            self.dotHasBeenPressed = YES;
        }
    }
    if (self.userIsInTheMiddleOfEnteringANumber){
        self.display.text = [self.display.text stringByAppendingString:numberToBeDisplayed];
    } else {
        self.display.text = numberToBeDisplayed;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    //self.operandDisplay.text = [self.brain updateProgramDescription];
     self.previousKeyWasOperation=NO;

}
- (IBAction)variablePressed:(id)sender {
    NSString *variable = [sender currentTitle];
    
    [self.brain pushVariable:variable];
    if (self.userIsInTheMiddleOfEnteringANumber){
        self.display.text = [self.display.text stringByAppendingString:variable];
    } else {
        self.display.text = variable;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    //self.operandDisplay.text = [[self.operandDisplay.text stringByAppendingString: @","] stringByAppendingString:[self.brain updateProgramDescription]];
    self.previousKeyWasOperation=NO;
}

- (IBAction)UndoPressed:(id)sender {

    if (self.userIsInTheMiddleOfEnteringANumber){
        if ([self.display.text length]  > 0){
            self.display.text = [self.display.text substringToIndex:[self.display.text length] -1];
        }else{
            self.display.text = [NSString stringWithFormat:@"%f", [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    } else {
        [self.brain clearLastInput];
        self.display.text = [self.brain returnLastInput];
        //self.previousStackContent = @"";
        self.operandDisplay.text = [self.brain updateProgramDescription];
        self.previousStackContent= @"";
    }
    self.previousKeyWasOperation=NO;
   
}

- (IBAction)enterPressed 
{
    NSRange range = [self.display.text rangeOfString:@"."];
    NSUInteger nextSubstringStartingPoint = range.location+1;
    NSRange isItXVariable = [self.display.text rangeOfString:@"x"];
    NSRange isItYVariable = [self.display.text rangeOfString:@"y"];
    NSRange isItAVariable = [self.display.text rangeOfString:@"a"];
    if (isItXVariable.location == NSNotFound && isItYVariable.location == NSNotFound && isItAVariable.location == NSNotFound){
        if (range.location == NSNotFound){
            [self.brain pushOperand:[self.display.text doubleValue]];
        } else {
            //Handle numbers with decimal points
            if ([[self.display.text substringFromIndex:nextSubstringStartingPoint] rangeOfString:@"."].location == NSNotFound){
                [self.brain pushOperand:[self.display.text doubleValue]];
            }else {
                [self.brain pushOperand:0];
            }
        }
    }
            
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.dotHasBeenPressed = NO;
    NSString *currentText = self.operandDisplay.text;
    
    if (!self.previousKeyWasOperation){
        self.operandDisplay.text = [[[self.brain updateProgramDescription]stringByAppendingString:@","] stringByAppendingString:currentText];
    }
    self.previousKeyWasOperation=NO;
}

- (IBAction)clearButtonPressed {
    self.display.text = @"0";
    self.operandDisplay.text =@"";
    self.previousStackContent = nil;
    self.previousKeyWasOperation=NO;
    self.userIsInTheMiddleOfEnteringANumber=NO;
    [self.brain clearAllOperands];

    for (NSString *key in [self.testVariableValues allKeys]){
        [self.testVariableValues setValue:[NSNumber numberWithDouble: 0] forKey:key];
    }
}

- (IBAction)operationPressed:(id)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber){
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
 
    [self.brain performOperation:operation];
    double result =  [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", result];

    if (self.previousStackContent == nil || self.previousKeyWasOperation) {
        self.operandDisplay.text = [self.brain updateProgramDescription];
    } else {
        self.operandDisplay.text = [[[self.brain updateProgramDescription]stringByAppendingString:@", "] stringByAppendingString:self.previousStackContent];
        
        //[[self.previousStackContent stringByAppendingString:@", "] stringByAppendingString:[self.brain updateProgramDescription]];
    }
    self.previousStackContent = self.operandDisplay.text;
    self.previousKeyWasOperation=YES;
    
}

- (void)viewDidUnload {
    [self setOperandDisplay:nil];
    [super viewDidUnload];
}
@end
