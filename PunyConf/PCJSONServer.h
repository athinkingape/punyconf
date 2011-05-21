#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol PCJSONServerDelegate <NSObject>
- (id)currentConfiguration;
@end

@interface PCJSONServer : NSObject <GCDAsyncSocketDelegate>
{
    id<PCJSONServerDelegate> delegate;
@private
    GCDAsyncSocket *listenSocket;
}

@property (assign) id<PCJSONServerDelegate> delegate;

- (BOOL)listen;

@end
