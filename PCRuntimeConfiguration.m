//
//  PCRuntimeConfiguration.m
//  Fresco
//
//  Created by Paul Collier on 11-05-19.
//  Copyright 2011 A Thinking Ape. All rights reserved.
//

#import "PCRuntimeConfiguration.h"
#import "JSONKit.h"

static const NSString *PC_HOST = @"localhost";
static const int PC_PORT = 47477;
static const float PC_TIMEOUT = 1.5;

@implementation PCRuntimeConfiguration

- (id)initWithTarget:(id)aTarget selector:(SEL)sel
{
    self = [super init];
    if (self)
    {
        target = [aTarget retain];
        selector = sel;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/", PC_HOST, PC_PORT]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:PC_TIMEOUT];
        conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (!conn)
        {
            [target performSelector:selector withObject:nil];
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Run-time config: %@", [error localizedDescription]);
    [target performSelector:selector withObject:nil];
    [conn release];
    conn = nil;
    [target release];
    target = nil;

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] == 200)
    {
        long long len = [httpResponse expectedContentLength];
        resp = [[NSMutableData alloc] initWithCapacity:MIN(len, 0)];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [resp appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [target performSelector:selector withObject:[resp objectFromJSONData]];
    [resp release];
    resp = nil;
    [conn release];
    conn = nil;
    [target release];
    target = nil;
}

- (void)dealloc
{
    [resp release];
    [conn cancel];
    [conn release];
    [target release];
    [super dealloc];
}

@end
