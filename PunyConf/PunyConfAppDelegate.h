#import <Cocoa/Cocoa.h>
#import "PCJSONServer.h"

@class PCPreferences;
@class PreferencesWindowController;

@interface PunyConfAppDelegate : NSObject <NSApplicationDelegate, PCJSONServerDelegate> {
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
