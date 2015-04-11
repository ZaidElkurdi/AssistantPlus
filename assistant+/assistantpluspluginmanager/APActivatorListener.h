//
//  APActivatorListener.h
//  
//
//  Created by Zaid Elkurdi on 4/2/15.
//
//

#import <Foundation/Foundation.h>

@interface APActivatorListener : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *triggerStrings;
@property (strong, nonatomic) NSArray *triggers;
@property (strong, nonatomic) NSString *identifier;
@property (nonatomic) BOOL willPassthrough;
- (id)initWithDictionary:(NSDictionary*)dict;
@end
