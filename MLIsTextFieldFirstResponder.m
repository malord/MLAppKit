#import "MLIsTextFieldFirstResponder.h"

void NeedMLIsTextFieldFirstResponder(void)
{
	// This is a dummy function so I have something to force this protocol to be linked.
}

@implementation NSTextField (MLIsTextFieldFirstResponder)

- (BOOL)isFirstResponderForWindow
{
	if ([[self window] firstResponder] == self)
		return YES;
		
	if ([[[self window] firstResponder] isKindOfClass:[NSTextView class]] && [[self window] fieldEditor:NO forObject:nil] != nil) {
		NSTextField *field = (NSTextField *) [(NSTextView *)[[self window] firstResponder] delegate];
		return field == self;
	}
	
	return NO;
}

@end
