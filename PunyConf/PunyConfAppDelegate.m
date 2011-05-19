#import "PunyConfAppDelegate.h"

@implementation PunyConfAppDelegate

@synthesize menuBarExtra;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Who needs a NIB anyway?");
}

- (void)awakeFromNib
{
    NSLog(@"Got nib.");
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:24] retain];
    [statusItem setMenu:menuBarExtra];
    [statusItem setImage:[NSImage imageNamed:@"local.png"]];
    [statusItem setAlternateImage:[NSImage imageNamed:@"local-alt.png"]];
    [statusItem setHighlightMode:YES];
}

- (void)dealloc
{
    [statusItem release];
}

@end
