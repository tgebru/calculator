//
//  CalculatorBrain.m
//  Calculator
//
//  Created by timnit gebru on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"
#import <objc/runtime.h>
@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
//@property (nonatomic, strong) NSMutableSet *setOfVariablesInProgram; 
@property (nonatomic, strong) NSDictionary *testVariables; 

//Internal sets
//@property (nonatomic, strong) NSSet *setOfOperations;
@end


@implementation CalculatorBrain

@synthesize programStack = _programStack;
//@synthesize setOfVariablesInProgram=_setOfVariablesInProgram;
@synthesize testVariables=_testVariables;

static NSSet *_setOfOperations; 
static NSSet *_setOfSingleOperandOperations;
static NSSet *_setOfDoubleOperandOperations;
static NSSet *_setOfNoOperandOperations;
static NSMutableSet *_setOfVariablesInProgram;



+ (NSSet *) setOfOperations {
  
    if (! _setOfOperations){
        _setOfOperations=[NSSet setWithObjects:@"+", @"-", @"*", @"/",@"π",@"sin", @"cos", @"sqrt", nil];
    }
    return _setOfOperations;
}

+ (NSSet *) setOfSingleOperandOperations {
    if (! _setOfSingleOperandOperations){
        _setOfSingleOperandOperations=[NSSet setWithObjects:@"sin", @"cos", @"sqrt", nil];
    }
    return _setOfSingleOperandOperations;
}

+ (NSSet *) setOfDoubleOperandOperations {
    if (! _setOfDoubleOperandOperations){
        _setOfDoubleOperandOperations=[NSSet setWithObjects:@"+", @"-", @"*", @"/", nil];
    }
    return _setOfDoubleOperandOperations;
}

+ (NSSet *) setOfNoOperandOperations {
    if (! _setOfNoOperandOperations){
        _setOfNoOperandOperations=[NSSet setWithObjects:@"π", nil];
    }
    return _setOfNoOperandOperations;
}

+(NSMutableSet *)setOfVariablesInProgram {
    if (!_setOfVariablesInProgram){
        _setOfVariablesInProgram=[[NSMutableSet alloc]init];
    }
    return _setOfVariablesInProgram;
}

-(void)clearLastInput
{
    if (self.programStack != nil){
        if ([self.programStack lastObject]) [self.programStack removeLastObject];
    }
}

-(NSString*)returnLastInput
{
   
    if ([self.programStack lastObject]){
     if ([[self.programStack lastObject] isKindOfClass:[NSString class]])
             return [self.programStack lastObject];
    }
    return [[self.programStack lastObject] stringValue];
}

-(NSMutableArray *)programStack
{
    if (!_programStack){
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

-(NSDictionary *)testVariables
{
    if (!_testVariables){
        _testVariables = [[NSDictionary alloc] init];
    }
    return _testVariables;
}


-(id)program
{
    return [self.programStack copy];
}

- (NSString*)updateProgramDescription
{
    NSMutableArray *stack;
    stack = [self.program mutableCopy];
    NSUInteger zero;
    zero = 0;
    
    NSString *description= [[self class] descriptionOfProgram:stack];
    if (description && [description length]!= 0){
        //Strip outside parentheses
        if ([[description substringToIndex:1] isEqualToString:@"("]){
        return [description substringWithRange:NSMakeRange(1, [description length]-2)];
        }
    }
        
    return description;
}


+ (BOOL)isOperation:(NSString *)string
{
 /*   
    NSLog([[[self.setOfOperations containsObject:string] ? @"YES" :@ "NO" stringByAppendingString: @": "] stringByAppendingString:string], @"%s");
    for (NSString * set in self.setOfOperations){
        NSLog(set, @"%s");
    }
  */
    return([[self setOfOperations]  containsObject:string]);
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray*)stack 
{
    NSString * result = @"";
   
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]){
        result = [NSString stringWithString:[topOfStack stringValue]];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]){
        NSString *operationOrVariable = topOfStack;
        if ([self isOperation:operationOrVariable]){
           if ([self.setOfDoubleOperandOperations containsObject:operationOrVariable]){
                
                NSString * secondOperand= [[self descriptionOfTopOfStack:stack] stringByAppendingString:@")"]; 
                NSString * firstOperand = [@"(" stringByAppendingString:[self descriptionOfTopOfStack:stack]];
            
                //Nicely format the display output. Eg for 3E5E6+* show 6*(3+6)
                result = [result stringByAppendingString:[[[[firstOperand stringByAppendingString:@" "] stringByAppendingString:operationOrVariable] stringByAppendingString:@" "] stringByAppendingString:secondOperand]]; 
           } else if ([self.setOfSingleOperandOperations containsObject:operationOrVariable]){
               result = [[[operationOrVariable stringByAppendingString:@" (" ] stringByAppendingString:[self descriptionOfTopOfStack:stack]]
                         stringByAppendingString:@") "];
           } else if ([self.setOfNoOperandOperations containsObject:operationOrVariable]){
             
               result = [NSString stringWithString:operationOrVariable];
           }
        } else {
               result = [NSString stringWithString:topOfStack];
        }
    }
    return result;
}

+(NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self descriptionOfTopOfStack:stack];    
    
}

- (void)pushOperand: (double) operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject: variable];
    //[self.setOfVariablesInProgram addObject: variable];
}

//-(double)performOperation:(NSString *)operation
-(void)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
  /*  
    if ([self.setOfVariablesInProgram count] !=0 )  return [[self class] runProgram:self.program usingVariableValues:self.testVariables];    
    return [[self class] runProgram:self.program];
  */ 
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    double pi  = 3.14;
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]){
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]){
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([@"*" isEqualToString:operation]){
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]){
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack]-subtrahend;
        } else if ([operation isEqualToString:@"/"]){
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack]/divisor;
        } else if ([operation isEqualToString:@"sin"]){
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"cos"]){
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"sqrt"]){
            result = sqrt([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"π"]){
            result = pi;
        }
    }
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        
        for (int i=0; i<[stack count]; i++){
         /*  
            NSString * name = [NSString stringWithUTF8String:
                               class_getName([[stack objectAtIndex:i]class])];
            NSLog(name, @"%s");
          */
            NSLog(@"running only runProgram");
            if (![[stack objectAtIndex:i] isKindOfClass:[NSNumber class]] && ![self isOperation:(NSString *)[stack objectAtIndex:i]]){
                [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithInt: 0]];
            }
        }
        
    }
  
    return [self popOperandOffProgramStack:stack];
}

+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues;
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    
        for (int i=0; i<[stack count]; i++){
            if ([variableValues objectForKey: [stack objectAtIndex:i]]){
                [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:[stack objectAtIndex:i]]];
            }
        }
    }
      return [self popOperandOffProgramStack:stack];          
}


+ (NSSet *) variablesUsedInProgram:(id)program
{
    NSMutableArray *stack;

    [self.setOfVariablesInProgram removeAllObjects];
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        
        for (id object in stack){
            if ([object isKindOfClass:[NSString class]]){
                if (![self isOperation:(NSString *)object]){
                    [self.setOfVariablesInProgram addObject:(NSString*) object];
                }
            }
        }
    }
    if ([self.setOfVariablesInProgram count] == 0) return nil;
    return self.setOfVariablesInProgram;

}
- (void)clearAllOperands
{
   if (self.programStack) [self.programStack removeAllObjects];
}


@end
