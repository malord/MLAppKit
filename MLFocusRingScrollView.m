#import "MLFocusRingScrollView.h"

@implementation MLFocusRingScrollView

- (BOOL)needsDisplay
{
	NSResponder *responder = nil;
	NSWindow *window = self.window;

	if (window.isKeyWindow) {
		responder = window.firstResponder;
		if (responder == _mlLastResponder)
			return super.needsDisplay;
	} else if (_mlLastResponder == nil) {
		return super.needsDisplay;
	}

	_mlShouldDrawFocusRing = (responder && [responder isKindOfClass:[NSView class]] && [(NSView *)responder isDescendantOf:self]);
	_mlLastResponder = responder;

	[self setKeyboardFocusRingNeedsDisplayInRect:self.bounds];
	return YES;
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	if (_mlShouldDrawFocusRing) {
		[NSGraphicsContext saveGraphicsState];
		NSSetFocusRingStyle(NSFocusRingOnly);
		[[NSColor keyboardFocusIndicatorColor] set];
		NSRectFill([self bounds]);
		[NSGraphicsContext restoreGraphicsState];
		// NSLog(@"drawing focus ring\n");
	}
} 

@end
