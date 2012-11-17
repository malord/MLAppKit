#include "MLLogWindowController.h"
#include <Foundation/NSRunLoop.h>

@interface MLLogWindowQueuedLog : NSObject {
	char *text;
	NSDictionary *attributes;
	MLLogWindowShowCommand showCommand;
}

- (id)initWithText:(const char *)text attributes:(NSDictionary *)attributes showCommand:(MLLogWindowShowCommand)showCommand;

- (const char *)text;
- (NSDictionary *)attributes;
- (MLLogWindowShowCommand)showCommand;

@end

@implementation MLLogWindowQueuedLog

- (id)initWithText:(const char *)aText attributes:(NSDictionary *)aAttributes showCommand:(MLLogWindowShowCommand)aShowCommand
{
	if (self = [super init], ! self)
		return nil;

	text = strdup(aText);
	attributes = [aAttributes retain];
	showCommand = aShowCommand;

	return self;
}

- (void)dealloc
{
	free(text);
	[attributes release];

	[super dealloc];
}

- (const char *)text
{
	return text;
}

- (NSDictionary *)attributes
{
	return attributes;
}

- (MLLogWindowShowCommand)showCommand
{
	return showCommand;
}

@end

@implementation MLLogWindowController

- (id)init
{
	return [self initWithTitle:@"Log Window"];
}

- (id)initWithTitle:(NSString *)title
{
	if (self = [super init], ! self)
		return nil;

	NSRect rect = NSMakeRect(0, 0, 600, 400);
	const int styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;

	window = [[NSWindow alloc] initWithContentRect:rect styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
	[window setFrameAutosaveName:@"MLLogWindowWindow"];
	[window setTitle:title];
	[window setReleasedWhenClosed:NO];

	NSScrollView *scrollView;
	scrollView = [[NSScrollView alloc] initWithFrame:[[window contentView] bounds]];
	[scrollView setHasVerticalScroller:YES];
	[scrollView setHasHorizontalScroller:NO];
	[scrollView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];

	[[scrollView contentView] setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
	[[scrollView contentView] setAutoresizesSubviews:YES];

	textView = [[NSTextView alloc] initWithFrame:[[scrollView contentView] bounds]];
	[textView setRichText:YES];
	[textView setEditable:NO];
	[textView setHorizontallyResizable:NO];
	[textView setVerticallyResizable:YES];
	[textView setMinSize:NSMakeSize(0, 0)];
	[textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
	[textView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];

	[[textView textContainer] setContainerSize:NSMakeSize([textView bounds].size.width, FLT_MAX)];
	[[textView textContainer] setWidthTracksTextView:YES];

	[scrollView setDocumentView:textView];
	[textView release];

	[window setContentView:scrollView];
	[scrollView release];

	windowEverShown = NO;

	return self;
}

- (void)dealloc
{
	[window release];

	[super dealloc];
}

// [NSWindow orderBack] sends the window to the back of the screen, behind other applications. What I want is for the
// window to be visible to the user immediately, but to not get in the way while they're using the app. This function
// finds the application's key window and places the log window directly beneath it.
static void PlaceWindowBelowKeyWindow(NSWindow *windowToPlace)
{
	NSWindow *key = [NSApp keyWindow];
	if (key) {
		[windowToPlace orderWindow:NSWindowBelow relativeTo:[key windowNumber]];
	} else {
		// If there's no key window, make the log window it.
		[windowToPlace makeKeyAndOrderFront:windowToPlace];
	}
}

- (void)_appendLog:(const char *)text attributes:(NSDictionary *)attributes showCommand:(MLLogWindowShowCommand)showCommand;
{
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithUTF8String:text] attributes:attributes];

	[[textView textStorage] replaceCharactersInRange:NSMakeRange([[textView textStorage] length], 0) withAttributedString:attributedString];

	[attributedString release];

	[textView scrollRangeToVisible:NSMakeRange([[textView textStorage] length], 0)];

	bool alert = showCommand >= MLLogWindowShowAlert;
	bool show = showCommand >= MLLogWindowShowShowInBackgroundIfInvisible;

	// If the window has been shown before but is no longer visible then the user closed it, in which case only re-display it if it's an alert.
	if (alert || (show && ! windowEverShown)) {
		windowEverShown = YES;

		if (! [window isVisible] || alert) {
			if (showCommand >= MLLogWindowShowShowInForegroundIfInvisible)
				[window makeKeyAndOrderFront:self];
			else
				PlaceWindowBelowKeyWindow(window);
		}
	}
}

- (void)_appendQueuedLog:(MLLogWindowQueuedLog *)queuedLog
{
	[self _appendLog:[queuedLog text] attributes:[queuedLog attributes] showCommand:[queuedLog showCommand]];
}

- (void)appendLog:(const char *)text color:(NSColor *)color showCommand:(MLLogWindowShowCommand)showCommand;
{
	NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:color, NSForegroundColorAttributeName, nil];
	[self appendLog:text attributes:attributes showCommand:showCommand];
	[attributes release];
}

- (void)appendLog:(const char *)text attributes:(NSDictionary *)attributes showCommand:(MLLogWindowShowCommand)showCommand
{
	MLLogWindowQueuedLog *queuedLog = [[MLLogWindowQueuedLog alloc] initWithText:text attributes:attributes showCommand:showCommand];
	[self performSelectorOnMainThread:@selector(_appendQueuedLog:) withObject:queuedLog waitUntilDone:NO];
	[queuedLog release];
}

- (void)_setVisible:(NSNumber *)visible
{
	if ([visible boolValue]) {
		if (! [window isVisible]) {
			if (setVisibleInBackground)
				PlaceWindowBelowKeyWindow(window);
			else
				[window makeKeyAndOrderFront:self];
		}
	} else {
		if ([window isVisible])
			[window orderOut:self];
	}
}

- (void)setVisible:(BOOL)visible
{
	[self setVisible:visible inBackground:NO];
}

- (void)setVisible:(BOOL)visible inBackground:(BOOL)inBackground
{
	setVisibleInBackground = inBackground;
	[self performSelectorOnMainThread:@selector(_setVisible:) withObject:[NSNumber numberWithBool:visible] waitUntilDone:NO];
}

- (BOOL)isVisible
{
	return [window isVisible];
}

@end
