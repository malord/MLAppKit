#import <Cocoa/Cocoa.h>

/// This is an individual pane of a MLPreferencePanelController Preferences panel.
@interface MLPreferenceViewController : NSObject {
	IBOutlet NSView *view;

	NSString *title;
	NSString *ident;
	NSImage *image;
	NSWindow *preferencesPanelWindow;
}

// Retrieve the view that was loaded from the nib.
- (NSView *)view;

// The localized title of this preferences view.
- (NSString *)title;
- (void)setTitle:(NSString *)newTitle;

// The identifier is a unique, non-localized string that is used to identify this particular preferences panel.
- (NSString *)identifier;
- (void)setIdentifier:(NSString *)newIdentifier;

// Load a nib.
- (BOOL)loadViewNibNamed:(NSString *)nibName;

// The image that appears on the toolbar.
- (void)setImage:(NSImage *)anImage;
- (NSImage *)image;

// Specifies the NSWindow of the Preferences panel.
- (void)setPreferencesPanelWindow:(NSWindow *)window;
- (NSWindow *)preferencesPanelWindow;

// Called when this is made the active preference view.
- (void)activated;

// Return YES if the view should be resizable.
- (BOOL)isResizable;

@end
