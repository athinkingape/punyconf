#import "PunyConfAppDelegate.h"
#import "PCPreferences.h"


@implementation PunyConfAppDelegate

@synthesize menuBarExtra;
@synthesize configurationsHeaderItem;
@synthesize configurationsFooterItem;
@synthesize preferencesWindow;

- (void)awakeFromNib
{
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:24] retain];
    [statusItem setMenu:menuBarExtra];
    [statusItem setImage:[NSImage imageNamed:@"local.png"]];
    [statusItem setAlternateImage:[NSImage imageNamed:@"local-alt.png"]];
    [statusItem setHighlightMode:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    preferences = [[PCPreferences alloc] init];
    [preferences addObserver:self forKeyPath:@"configurations" options:NSKeyValueObservingOptionInitial context:nil];
    [preferences addObserver:self forKeyPath:@"selectedConfigurationIndex" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld) context:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
}

- (void)selectConfiguration:(id)sender
{
    preferences.selectedConfigurationIndex = [sender tag];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    const NSInteger listStart = [menuBarExtra indexOfItem:configurationsHeaderItem] + 1;
    if (object == preferences && [keyPath isEqualToString:@"configurations"])
    {
        // Re-populate configurations menu
        while ([menuBarExtra itemAtIndex:listStart] != configurationsFooterItem)
        {
            [menuBarExtra removeItemAtIndex:listStart];
        }
        for (NSUInteger i = 0; i < [preferences.configurations count]; i++)
        {
            NSMenuItem *configItem = [[NSMenuItem alloc] initWithTitle:[preferences titleForConfigurationAtIndex:i] action:@selector(selectConfiguration:) keyEquivalent:@""];
            [configItem setTarget:self];
            [configItem setTag:i];
            [menuBarExtra insertItem:configItem atIndex:listStart + i];
            [configItem release];
        }
    }
    else if (object == preferences && [keyPath isEqualToString:@"selectedConfigurationIndex"])
    {
        // Move checkmark
        NSNumber *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        if (oldValue)
        {
            NSInteger oldIndex = [oldValue integerValue];
            if (oldIndex != NSNotFound)
            {
                [[menuBarExtra itemAtIndex:listStart + oldIndex] setState:NSOffState];
            }
        }
        NSInteger newIndex = preferences.selectedConfigurationIndex;
        if (newIndex != NSNotFound)
        {
            [[menuBarExtra itemAtIndex:listStart + newIndex] setState:NSOnState];
            [configurationsHeaderItem setTitle:@"Configuration"];
        }
        else
        {
            [configurationsHeaderItem setTitle:@"No configuration selected"];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction)showPreferences:(id)sender
{
    if (!preferencesWindow)
    {
        NSWindowController *preferencesController = [[NSWindowController alloc] initWithWindowNibName:@"Preferences"];
        [preferencesController loadWindow];
        preferencesWindow = [[preferencesController window] retain];
        [preferencesController showWindow:sender];
        [preferencesController release];
    }
    // XXX: Focus it
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (preferencesWindow == [notification object])
    {
        [preferencesWindow release];
        preferencesWindow = nil;
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:nil];
    [preferences removeObserver:self forKeyPath:@"selectedConfigurationIndex"];
    [preferences removeObserver:self forKeyPath:@"configurations"];
}

- (void)dealloc
{
    [preferences release];
    [preferencesWindow release];
    [statusItem release];
    [super dealloc];
}

@end
