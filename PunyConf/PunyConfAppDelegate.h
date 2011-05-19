#import <Cocoa/Cocoa.h>

@class PCPreferences;
@class PreferencesWindowController;

@interface PunyConfAppDelegate : NSObject <NSApplicationDelegate> {
@private
    PCPreferences *preferences;
    PreferencesWindowController *preferencesController;

    NSStatusItem *statusItem;
    NSMenu *menuBarExtra;
    NSMenuItem *configurationsHeaderItem;
    NSMenuItem *configurationsFooterItem;
}

@property (assign) IBOutlet NSMenu *menuBarExtra;
@property (assign) IBOutlet NSMenuItem *configurationsHeaderItem;
@property (assign) IBOutlet NSMenuItem *configurationsFooterItem;

- (IBAction)showPreferences:(id)sender;

@end
