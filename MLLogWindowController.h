#import <Cocoa/Cocoa.h>

typedef enum MLLogWindowShowCommand {
	MLLogWindowShowNoChange = 0,
	MLLogWindowShowShowInBackgroundIfInvisible = 1,
	MLLogWindowShowShowInForegroundIfInvisible = 2,
	MLLogWindowShowAlert = 3
} MLLogWindowShowCommand;

/// A thread safe log window.
@interface MLLogWindowController : NSObject {
	NSWindow *window;
	NSTextView *textView;
	BOOL windowEverShown;
	BOOL setVisibleInBackground;
}

- (id)init;

- (id)initWithTitle:(NSString *)title;

- (void)appendLog:(const char *)text attributes:(NSDictionary *)attributes showCommand:(MLLogWindowShowCommand)showCommand;

/// This creates a new NSDictionary at each invokation, so if possible, use the attributes: version.
- (void)appendLog:(const char *)text color:(NSColor *)color showCommand:(MLLogWindowShowCommand)showCommand;

- (void)setVisible:(BOOL)visible;

- (void)setVisible:(BOOL)visible inBackground:(BOOL)inBackground;

- (BOOL)isVisible;

@end
