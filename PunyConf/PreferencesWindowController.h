#import <Cocoa/Cocoa.h>

@class PCPreferences;

@interface PreferencesWindowController : NSWindowController <NSOutlineViewDelegate> {
@private
    PCPreferences *preferences;
    NSOutlineView *preferencesOutline;
}
@property (assign) IBOutlet NSOutlineView *preferencesOutline;

- (id)initWithPreferences:(PCPreferences *)preferences;

@end
