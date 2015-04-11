#import "CPDistributedMessagingCenter.h"
#include <iostream>
#include <string>

int main(int argc, char **argv, char **envp) {
  NSString *toSay = nil;
  
  if (argc == 1) {
    NSMutableString *builder = [NSMutableString string];
    for (std::string line; std::getline(std::cin, line);) {
      [builder appendString:[NSString stringWithUTF8String:line.c_str()]];
    }
    toSay = builder;
  } else if (argc == 2) {
    toSay = [NSString stringWithUTF8String:argv[1]];
  }
  
  if (!toSay || toSay.length == 0) {
    return -1;
  }
  
  CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.springboard"];
  [center sendMessageName:@"siriSay" userInfo:@{@"message" : toSay}];
	return 0;
}

// vim:ft=objc
