#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"


@interface PCJSONServer : NSObject <GCDAsyncSocketDelegate>
{
@private
    GCDAsyncSocket *listenSocket;
}

- (BOOL)listen;

@end
