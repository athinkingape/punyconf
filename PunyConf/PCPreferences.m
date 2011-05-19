#import "PCPreferences.h"

static const CFStringRef kConfigurationsPrefKey = CFSTR("Configurations");
static const CFStringRef kSelectedConfigurationPrefKey = CFSTR("SelectedConfiguration");

@implementation PCPreferences

@synthesize configurations;
@synthesize selectedConfigurationIndex;

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
        selectedConfigurationIndex = CFPreferencesGetAppIntegerValue(kSelectedConfigurationPrefKey, kCFPreferencesCurrentApplication, &exists);
        if (!exists)
        {
            selectedConfigurationIndex = 0;
        }
        if (selectedConfigurationIndex < 0 || selectedConfigurationIndex >= [configurations count])
        {
            selectedConfigurationIndex = [configurations count] ? 0 : NSNotFound;
        }
    }

    return self;
}

- (NSString *)titleForConfigurationAtIndex:(NSUInteger)index
{
    return [[configurations objectAtIndex:index] objectForKey:@"host"];
}

// KVC compliance
- (void)insertObject:(id)object inConfigurationsAtIndex:(NSUInteger)index
{
    [configurations insertObject:object atIndex:index];
}

// KVC compliance
- (void)removeObjectFromConfigurationsAtIndex:(NSUInteger)index
{
    [configurations removeObjectAtIndex:index];
}

- (void)save
{
    CFPreferencesSetAppValue(kConfigurationsPrefKey, configurations, kCFPreferencesCurrentApplication);
}

- (void)dealloc
{
    [configurations release];
    [super dealloc];
}

@end
