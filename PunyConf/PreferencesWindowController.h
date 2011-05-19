#import <Cocoa/Cocoa.h>


@interface PreferencesWindowController : NSWindowController <NSOutlineViewDelegate> {
@private
    NSOutlineView *preferencesOutline;
}
@property (assign) IBOutlet NSOutlineView *preferencesOutline;

@end
