#import <Cocoa/Cocoa.h>

@class MLPreferenceViewController;

/// Provides a Mac style Preferences window, where the toolbar contains tabs that move between sections.
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@interface MLPreferencesPanelController : NSWindowController <NSToolbarDelegate>
#else
@interface MLPreferencesPanelController : NSWindowController
#endif
{
	NSToolbar *toolbar;
	NSMutableDictionary *itemsMap;
	NSMutableArray *itemsKeys;
	NSView *currentView;
}

// Displays the preferences panel and activates a specific view.
- (BOOL)activateViewWithIdentifier:(NSString *)viewName;

// Add an individual MLPreferenceViewController to be displayed. This must be called before the window is shown.
- (void)addViewController:(MLPreferenceViewController *)viewController;

@end
