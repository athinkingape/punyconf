#import "PCJSONServer.h"
#import "JSONKit.h"

static int serverPort = 47477;

@interface PCJSONSocketState : NSObject
@property (assign) int state;
@end

@implementation PCJSONSocketState
@synthesize state;
@end

@implementation PCJSONServer

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self)
    {
        listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
    }
    
    return self;
}

- (BOOL)listen
{
    NSError *error;
    if (![listenSocket acceptOnPort:serverPort error:&error])
    {
        [NSAlert alertWithError:error];
        return NO;
    }
    return YES;
}

#pragma mark - GCDAsyncSocketDelegate methods

- (dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock
{
    dispatch_queue_t queue = dispatch_get_current_queue();
    dispatch_retain(queue);
    return queue;
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    PCJSONSocketState *state = [[PCJSONSocketState alloc] init];
    [newSocket setUserData:state];
    [state release];
    [newSocket retain];
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    PCJSONSocketState *state = [sock userData];
    if (state)
    {
        id conf = [delegate currentConfiguration];
        NSMutableData *payload;
        if (conf)
        {
            NSData *json = [conf JSONData];
            int len = (int) [json length];
            NSData *header = [[NSString stringWithFormat:@"HTTP/1.1 200 OK\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length:%d\r\n\r\n", len] dataUsingEncoding:NSUTF8StringEncoding];
            payload = [[NSMutableData alloc] initWithCapacity:[header length] + len];
            [payload appendData:header];
            [payload appendData:json];
        }
        else
        {
            static const char httpResp[] = "HTTP/1.1 204 No Content\r\n\r\n";
            payload = [[NSData alloc] initWithBytesNoCopy:(void *)httpResp length:sizeof httpResp - 1 freeWhenDone:NO];
        }
        [sock writeData:payload withTimeout:-1 tag:0];
        [payload release];
        [sock disconnectAfterWriting];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err && [err code] != GCDAsyncSocketClosedError)
    {
        NSLog(@"%@", [err localizedDescription]);
    }
    [sock setDelegate:nil];
    [sock release];
}

- (void)dealloc
{
    [listenSocket setDelegate:nil];
    [listenSocket disconnect];
    [listenSocket release];
    [super dealloc];
}

@end
