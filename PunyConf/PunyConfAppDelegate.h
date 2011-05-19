#import <Cocoa/Cocoa.h>

@interface PunyConfAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSMenu *menuBarExtra;
    NSStatusItem *statusItem;
}

@property (assign) IBOutlet NSMenu *menuBarExtra;

@end
