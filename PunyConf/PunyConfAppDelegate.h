#import <Cocoa/Cocoa.h>

@class PCJSONServer;
@class PCPreferences;
@class PreferencesWindowController;

@interface PunyConfAppDelegate : NSObject <NSApplicationDelegate> {
@private
    PCPreferences *preferences;
    PreferencesWindowController *preferencesController;
    PCJSONServer *server;

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
