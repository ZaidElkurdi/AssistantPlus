//
//  APCaptureGroupCommand.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 4/14/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "APCaptureGroupCommand.h"

@implementation APCaptureGroupCommand {
  NSArray *variableRanges;
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
    self.trigger = [NSRegularExpression regularExpressionWithPattern:trigger options:NSRegularExpressionCaseInsensitive error:nil];
    self.uuid = uuid ? uuid : [NSString stringWithFormat:@"%@", [NSUUID UUID]];
    [self buildRangeDictionary];
  }
  return  self;
}

- (void)buildRangeDictionary {
  NSMutableArray *newVariableRanges = [[NSMutableArray alloc] init];
  for (NSString *currVariable in self.variables) {
    NSRange currRange = [self.command rangeOfString:[NSString stringWithFormat:@"[%@]", currVariable]];
    if (currRange.location != NSNotFound) {
      [newVariableRanges addObject:@[currVariable, [NSValue valueWithRange:currRange]]];
    }
  }
  
  //Sort the variables by location in order to calculate offset easily
  variableRanges = [newVariableRanges sortedArrayUsingComparator:^NSComparisonResult(NSArray *first, NSArray *second) {
    NSRange firstRange = [first[1] rangeValue];
    NSRange secondRange = [second[1] rangeValue];
    
    return firstRange.location > secondRange.location;
  }];
}

-(NSString*)buildCommandWithValues:(NSArray*)values {
  //First, map the captured values to their variable names
  NSMutableDictionary *variablesToValues = [[NSMutableDictionary alloc] init];
  NSInteger currIndex = 0;
  NSLog(@"Values: %@", values);
  for (NSString *currValue in values) {
    NSLog(@"On: %@", currValue);
    if (currIndex < self.variables.count) {
      NSLog(@"Adding: %@", currValue);
      NSString *currVariable = self.variables[currIndex];
      NSLog(@"Assigning to %@", currVariable);
      variablesToValues[currVariable] = currValue;
    }
    currIndex++;
  }
  
  //Second, check the conditionals to see
  for (NSArray *currRule in self.conditionals) {
    NSString *conditionalVariable = currRule[0];
    NSString *conditionalValue = currRule[1];
    NSString *targetVariable = currRule[2];
    NSString *targetValue = currRule[3];
    
    if (!conditionalVariable || !targetVariable || !conditionalValue || !targetValue) {
      continue;
    }
    
    NSString *actualValue = variablesToValues[conditionalVariable];
    if (actualValue) {
      if ([actualValue compare:conditionalValue options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        variablesToValues[targetVariable] = targetValue;
      }
    }
  }
  
  NSLog(@"Var to Val: %@", variablesToValues);
  NSMutableString *mutableCommand = [self.command mutableCopy];
  NSInteger offset = 0;
  for (NSArray *currVariablePair in variableRanges) {
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
