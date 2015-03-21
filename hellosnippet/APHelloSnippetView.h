//
//  HelloSnippetSnippet.h
//  
//
//  Created by Zaid Elkurdi on 3/14/15.
//
//

#import "AssistantPlusHeaders.h"

@interface APHelloSnippetView : UIViewController<APPluginSnippet, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,retain) AceObject *aceObject;
-(id)initWithProperties:(NSDictionary*)props;
@end
