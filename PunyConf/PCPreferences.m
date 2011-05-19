#import "PCPreferences.h"

static const CFStringRef kConfigurationsPrefKey = CFSTR("Configurations");
static const CFStringRef kSelectedConfigurationPrefKey = CFSTR("SelectedConfiguration");

@implementation PCPreferences

- (id)init
{
    self = [super init];
    if (self)
    {
        NSArray *prevConfs = CFPreferencesCopyAppValue(kConfigurationsPrefKey, kCFPreferencesCurrentApplication);
        if (prevConfs)
        {
            configurations = [[NSMutableArray alloc] initWithArray:prevConfs copyItems:YES];
            [prevConfs release];
        }
        else
        {
            configurations = [[NSMutableArray alloc] initWithObjects:[NSMutableDictionary dictionaryWithObject:@"localhost" forKey:@"host"], [NSMutableDictionary dictionaryWithObject:@"example.com" forKey:@"host"], nil];
        }

        Boolean exists;
        NSInteger index = CFPreferencesGetAppIntegerValue(kSelectedConfigurationPrefKey, kCFPreferencesCurrentApplication, &exists);
        if (!exists)
        {
            index = 0;
        }
        if (index < 0 || index >= [configurations count])
        {
            index = [configurations count] ? 0 : NSNotFound;
        }
        self.selectedConfigurationIndex = index;
    }

    return self;
}

#pragma mark - Data source

- (NSString *)titleForConfigurationAtIndex:(NSUInteger)index
{
    return [[configurations objectAtIndex:index] objectForKey:@"host"];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (!item)
    {
        return [configurations objectAtIndex:index];
    }
    else if ([item isKindOfClass:[NSDictionary class]])
    {
        // Not particularly fast...
        return [item objectForKey:[[item allKeys] objectAtIndex:index]];
    }
    else if ([item isKindOfClass:[NSArray class]])
    {
        return [item objectAtIndex:index];
    }
    else
    {
        return nil;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return ([item isKindOfClass:[NSDictionary class]] || [item isKindOfClass:[NSArray class]]) && [item count];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (!item)
    {
        return [configurations count];
    }
    else if ([item isKindOfClass:[NSDictionary class]] || [item isKindOfClass:[NSArray class]])
    {
        return [item count];
    }
    else
    {
        return 0;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if ([[tableColumn identifier] isEqualToString:@"Key"])
    {
        id parent = [outlineView parentForItem:item];
        if (!parent)
        {
            return [NSString stringWithFormat:@"Configuration #%d", (int) [configurations indexOfObject:item] + 1];
        }
        else if ([parent isKindOfClass:[NSDictionary class]])
        {
            return [[parent allKeysForObject:item] objectAtIndex:0];
        }
        else if ([parent isKindOfClass:[NSArray class]])
        {
            return [NSString stringWithFormat:@"Item #%d", (int) [parent indexOfObject:item] + 1];
        }
        else
        {
            return nil;
        }
    }
    else // Value column
    {
        if ([item isKindOfClass:[NSDictionary class]] || [item isKindOfClass:[NSArray class]])
        {
            int count = (int) [item count];
            return [NSString stringWithFormat:@"%d item%@", count, count == 1 ? @"" : @"s"];
        }
        else
        {
            return item;
        }
    }
}

#pragma mark - Persistence and observation

- (void)saveConfigurations
{
    CFPreferencesSetAppValue(kConfigurationsPrefKey, configurations, kCFPreferencesCurrentApplication);
    CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
}

- (void)setConfigurations:(NSMutableArray *)newConfs
{
    @synchronized(self)
    {
        [newConfs retain];
        [configurations release];
        configurations = newConfs;
        [self saveConfigurations];
    }
}

- (NSMutableArray *)configurations
{
    return configurations;
}

// KVC compliance
- (void)insertObject:(id)object inConfigurationsAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        [configurations insertObject:object atIndex:index];
        [self saveConfigurations];
    }
}

// KVC compliance
- (void)removeObjectFromConfigurationsAtIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        [configurations removeObjectAtIndex:index];
        [self saveConfigurations];
    }
}

- (NSInteger)selectedConfigurationIndex
{
    return selectedConfigurationIndex;
}

- (void)setSelectedConfigurationIndex:(NSInteger)index
{
    @synchronized(self)
    {
        selectedConfigurationIndex = index;
        CFPreferencesSetAppValue(kSelectedConfigurationPrefKey, [NSNumber numberWithInteger:index], kCFPreferencesCurrentApplication);
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
    }
}

#pragma mark - Mutation

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if ([[tableColumn identifier] isEqualToString:@"Value"])
    {
        id parent = [outlineView parentForItem:item];
        if ([parent isKindOfClass:[NSDictionary class]])
        {
            [parent setObject:object forKey:[[parent allKeysForObject:item] objectAtIndex:0]];
        }
        else if ([parent isKindOfClass:[NSArray class]])
        {
            [parent replaceObjectAtIndex:[parent indexOfObject:item] withObject:object];
        }
        // Trigger reload (eek)
        self.configurations = configurations;
    }
}

- (void)dealloc
{
    [configurations release];
    [super dealloc];
}

@end
