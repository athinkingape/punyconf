#import "PCJSONServer.h"
#import "JSONKit.h"

static int serverPort = 47477;

typedef enum {
    PCJSStateHeader,
    PCJSStateR,
    PCJSStateRN,
    PCJSStateRNR,
    PCJSStateDone
} PCJSState;

@interface PCJSContext : NSObject
{
    int state;
}
@property (assign) int state;
@end

@implementation PCJSContext
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
    PCJSContext *context = [[PCJSContext alloc] init];
    context.state = PCJSStateHeader;
    [newSocket setUserData:context];
    [context release];
    [newSocket retain];
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)sendCurrentConfigurationToSocket:(GCDAsyncSocket *)sock
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
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // Look for the \r\n
    PCJSContext *context = [sock userData];
    PCJSState state = context.state;
    const char *buf = [data bytes];
    for (NSUInteger i = 0, len = [data length]; i < len && state != PCJSStateDone; i++)
    {
        char c = buf[i];
        switch (state)
        {
            case PCJSStateHeader:
                if (c == '\r')
                    state = PCJSStateR;
                break;
            case PCJSStateR:
                if (c == '\n')
                    state = PCJSStateRN;
                else if (c != '\r')
                    state = PCJSStateHeader;
                break;
            case PCJSStateRN:
                if (c == '\r')
                    state = PCJSStateRNR;
                else
                    state = PCJSStateHeader;
                break;
            case PCJSStateRNR:
                if (c == '\n')
                {
                    state = PCJSStateDone;
                    [self sendCurrentConfigurationToSocket:sock];
                    [sock disconnectAfterWriting];
                }
                else
                {
                    state = (c == '\r') ? PCJSStateR : PCJSStateHeader;
                }
                break;
            case PCJSStateDone:
                break;
        }
    }
    context.state = state;
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
