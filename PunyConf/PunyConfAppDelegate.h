#import <Cocoa/Cocoa.h>

@class PCPreferences;

@interface PunyConfAppDelegate : NSObject <NSApplicationDelegate> {
@private
    PCPreferences *preferences;
    NSWindow *preferencesWindow;

    NSStatusItem *statusItem;
    NSMenu *menuBarExtra;
    NSMenuItem *configurationsHeaderItem;
    NSMenuItem *configurationsFooterItem;
}

@property (assign) IBOutlet NSMenu *menuBarExtra;
@property (assign) IBOutlet NSMenuItem *configurationsHeaderItem;
@property (assign) IBOutlet NSMenuItem *configurationsFooterItem;
@property (assign) IBOutlet NSWindow *preferencesWindow;

- (IBAction)showPreferences:(id)sender;

@end
