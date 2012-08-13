//
//  CalculatorBrain.h
//  Calculator
//
//  Created by timnit gebru on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject
- (void)pushOperand:(double)operand;
- (void)pushVariable:(NSString*)variable;
- (void)clearAllOperands;
- (void)clearLastInput;
- (NSString *)returnLastInput;
//- (double)performOperation: (NSString *) operation;
- (void)performOperation: (NSString *) operation;
- (NSString *) updateProgramDescription;

@property (nonatomic, readonly) id program;
+ (NSString*) descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *) variablesUsedInProgram: (id) program;

@end
