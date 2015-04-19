//
//  APCaptureGroupCommand.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 4/14/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "APCaptureGroupCommand.h"

@implementation APCaptureGroupCommand {
  NSArray *commandVariableRanges;
  NSArray *triggerVariableRanges;
}

-(id)initWithDictionary:(NSDictionary*)dict {
  if (self = [super init]) {
    NSString *name = dict[@"name"];
    NSArray *variables = dict[@"variables"];
    NSArray *conditionals = dict[@"conditionals"];
    NSString *command = dict[@"command"];
    NSString *trigger = dict[@"trigger"];
    NSString *uuid = dict[@"uuid"];
    
    self.name = name;
    self.variables = variables ? variables : [NSArray array];
    self.conditionals = conditionals ? conditionals : [NSArray array];
    self.command = command ? command : @"";
    self.uuid = uuid ? uuid : [NSString stringWithFormat:@"%@", [NSUUID UUID]];
    
    [self buildRangeDictionariesWithTrigger:trigger andCommand:self.command];
    self.trigger = [self buildRegularExpressionWithString:trigger];
  }
  return  self;
}

- (void)buildRangeDictionariesWithTrigger:(NSString*)trigger andCommand:(NSString*)command {
  NSMutableArray *newCommandVariableRanges = [[NSMutableArray alloc] init];
  NSMutableArray *newTriggerVariableRanges = [[NSMutableArray alloc] init];
  
  for (NSArray *currVariableInfo in self.variables) {
    NSString *currVariable = [NSString stringWithFormat:@"\\[%@\\]", currVariableInfo[0]];
    NSLog(@"Expression: %@", currVariable);
    NSRegularExpression *currExpression = [NSRegularExpression regularExpressionWithPattern:currVariable options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *triggerMatches = [currExpression matchesInString:trigger options:0 range:NSMakeRange(0, [trigger length])];
    for (NSTextCheckingResult *match in triggerMatches) {
      if (match.numberOfRanges > 0) {
        for (NSInteger currIndex = 0; currIndex < match.numberOfRanges; currIndex++) {
          NSString *variableValue = [[trigger substringWithRange:[match rangeAtIndex:currIndex]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
          NSLog(@"Trigger Match %ld: %@", (long)currIndex, variableValue);
          [newTriggerVariableRanges addObject:@[currVariableInfo[0], [NSValue valueWithRange:[match rangeAtIndex:currIndex]], currVariableInfo[1]]];
        }
      }
    }
    
    NSArray *commandMatches = [currExpression matchesInString:command options:0 range:NSMakeRange(0, [command length])];
    for (NSTextCheckingResult *match in commandMatches) {
      if (match.numberOfRanges > 0) {
        for (NSInteger currIndex = 0; currIndex < match.numberOfRanges; currIndex++) {
          NSString *variableValue = [[command substringWithRange:[match rangeAtIndex:currIndex]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
          NSLog(@"Command Match %ld: %@", (long)currIndex, variableValue);
          [newCommandVariableRanges addObject:@[currVariableInfo[0], [NSValue valueWithRange:[match rangeAtIndex:currIndex]]]];
        }
      }
    }
  }
  
  NSComparator rangeComparator = ^NSComparisonResult(NSArray *first, NSArray *second) {
    NSRange firstRange = [first[1] rangeValue];
    NSRange secondRange = [second[1] rangeValue];
    
    return firstRange.location > secondRange.location;
  };

  
  //Sort the variables by location in order to calculate offset easily
  commandVariableRanges = [newCommandVariableRanges sortedArrayUsingComparator:rangeComparator];
  triggerVariableRanges = [newTriggerVariableRanges sortedArrayUsingComparator:rangeComparator];
}

- (NSRegularExpression*)buildRegularExpressionWithString:(NSString*)triggerString {
  NSMutableString *mutableExpression = [triggerString mutableCopy];
  NSInteger offset = 0;
  for (NSArray *currVariablePair in triggerVariableRanges) {
    NSString *currVariable = currVariablePair[0];
    NSLog(@"Currently on %@", currVariable);
    if (!currVariable) {
      continue;
    }
    
    NSRange rangeToReplace = [currVariablePair[1] rangeValue];
    rangeToReplace.location += offset;
    
    [mutableExpression replaceCharactersInRange:rangeToReplace withString:@"(.*)"];
    offset += 4 - rangeToReplace.length;
  }
  NSLog(@"Finished trigger: %@", mutableExpression);
  return [NSRegularExpression regularExpressionWithPattern:mutableExpression options:NSRegularExpressionCaseInsensitive error:nil];
}

-(NSString*)buildCommandWithValues:(NSArray*)values {
  //First, map the captured values to their variable names
  NSMutableDictionary *variablesToValues = [[NSMutableDictionary alloc] init];
  NSInteger currIndex = 0;
  NSLog(@"Values: %@", values);
  for (NSString *currValue in values) {
    NSLog(@"On: %@", currValue);
    if (currIndex < triggerVariableRanges.count) {
      BOOL shouldEscape = [triggerVariableRanges[currIndex][2] boolValue];
      NSString *valueToSave = currValue;
      if (shouldEscape) {
        valueToSave = [currValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      NSLog(@"Adding: %@", valueToSave);
      NSString *currVariable = triggerVariableRanges[currIndex][0];
      NSLog(@"Assigning to %@", currVariable);
      variablesToValues[currVariable] = valueToSave;
    }
    currIndex++;
  }
  
  //Second, check the conditionals to see if we should reassign anything
  for (NSArray *currRule in self.conditionals) {
    NSString *conditionalVariable = currRule[0];
    NSString *conditionalValue = currRule[1];
    NSString *targetVariable = currRule[2];
    NSString *targetValue = currRule[3];
    
    if (!conditionalVariable || !targetVariable || !conditionalValue || !targetValue) {
      continue;
    }
    
    NSLog(@"V to V: %@", variablesToValues);
    NSString *actualValue = variablesToValues[conditionalVariable];
    NSLog(@"Actual: %@ Conditional: %@", actualValue, conditionalValue);
    if (actualValue) {
      if ([actualValue compare:conditionalValue options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        variablesToValues[targetVariable] = targetValue;
      }
    }
  }
  
  NSLog(@"Var to Val: %@", variablesToValues);
  NSLog(@"Command to Val: %@", commandVariableRanges);
  NSMutableString *mutableCommand = [self.command mutableCopy];
  NSInteger offset = 0;
  for (NSArray *currVariablePair in commandVariableRanges) {
    NSString *currVariable = currVariablePair[0];
    NSString *currValue = variablesToValues[currVariable];
    NSLog(@"Currently on %@ %@", currVariable, currValue);
    if (!currVariable || !currValue) {
      continue;
    }
    
    NSRange rangeToReplace = [currVariablePair[1] rangeValue];
    rangeToReplace.location += offset;
    
    [mutableCommand replaceCharactersInRange:rangeToReplace withString:currValue];
    offset += currValue.length - rangeToReplace.length;
  }
  return mutableCommand;
}

@end
