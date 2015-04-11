//
//  APActivatorListener.h
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/22/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APActivatorListener : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *triggers;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL willPassthrough;
@property (nonatomic, strong) NSString *uniqueId;

-(id)initWithDictionary:(NSDictionary*)dict;
- (NSDictionary*)dictionaryRepresentation;

@end
