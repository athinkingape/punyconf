#import "PreferencesWindowController.h"


@implementation PreferencesWindowController

@synthesize preferencesOutline;

- (void)dealloc
{
    [super dealloc];
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

@end
