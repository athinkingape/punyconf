#import "PreferencesWindowController.h"
#import "PCPreferences.h"

@implementation PreferencesWindowController

@synthesize preferencesOutline;

- (id)initWithPreferences:(PCPreferences *)prefs
{
    self = [super initWithWindowNibName:@"Preferences"];
    if (self)
    {
        preferences = [prefs retain];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [preferencesOutline setDataSource:preferences];
    [preferencesOutline reloadData];
    for (id item in preferences.configurations)
    {
        [preferencesOutline expandItem:item];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if (!item || [item isKindOfClass:[NSDictionary class]] || [item isKindOfClass:[NSArray class]])
    {
        return NO;
    }
    else
    {
        return [[tableColumn identifier] isEqualToString:@"Value"];
    }
}

- (void)dealloc
{
    [preferences release];
    [super dealloc];
}

@end
