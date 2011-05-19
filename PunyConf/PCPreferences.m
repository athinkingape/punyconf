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
            configurations = [[NSMutableArray alloc] initWithArray:prevConfs];
            [prevConfs release];
        }
        else
        {
            configurations = [[NSMutableArray alloc] initWithObjects:[NSDictionary dictionaryWithObject:@"localhost" forKey:@"host"], [NSDictionary dictionaryWithObject:@"example.com" forKey:@"host"], nil];
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

- (NSString *)titleForConfigurationAtIndex:(NSUInteger)index
{
    return [[configurations objectAtIndex:index] objectForKey:@"host"];
}

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

- (void)dealloc
{
    [configurations release];
    [super dealloc];
}

@end
