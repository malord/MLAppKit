//
//  KBPopUpToolbarItem.m
//  --------------------
//
//  Created by Keith Blount on 14/05/2006.
//  Copyright 2006 Keith Blount. All rights reserved.
//

// This version is extended to support menu-only buttons.

#import "MLKBPopUpToolbarItem.h"

@interface KBDelayedPopUpButtonCell : NSButtonCell
{
	// ML: added
	BOOL menuOnly;
}

// ML: added
- (void)setMenuOnly:(BOOL)to;

@end

@implementation KBDelayedPopUpButtonCell

// ML: added
- (void)setMenuOnly:(BOOL)to
{
	menuOnly = to;
}

- (NSPoint)menuPositionForFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSPoint result = [controlView convertPoint:cellFrame.origin toView:nil];
	result.x += 1.0f;
	result.y -= cellFrame.size.height + 5.5f;
	return result;
}

- (void)showMenuForEvent:(NSEvent *)theEvent controlView:(NSView *)controlView cellFrame:(NSRect)cellFrame
{
	NSPoint menuPosition = [self menuPositionForFrame:cellFrame inView:controlView];

	// Create event for pop up menu with adjusted mouse position
	NSEvent *menuEvent = [NSEvent mouseEventWithType:[theEvent type]
											location:menuPosition
									   modifierFlags:[theEvent modifierFlags]
										   timestamp:[theEvent timestamp]
										windowNumber:[theEvent windowNumber]
											 context:[theEvent context]
										 eventNumber:[theEvent eventNumber]
										  clickCount:[theEvent clickCount]
											pressure:[theEvent pressure]];

	[NSMenu popUpContextMenu:[self menu] withEvent:menuEvent forView:controlView];
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	// ML: added
	if (menuOnly)
	{
		[self showMenuForEvent:theEvent controlView:controlView cellFrame:cellFrame];
		return YES;
	}

	BOOL result = NO;
	NSPoint currentPoint = [theEvent locationInWindow];
	BOOL done = NO;
	BOOL trackContinously = [self startTrackingAt:currentPoint inView:controlView];

	// Catch next mouse-dragged or mouse-up event until timeout
	BOOL mouseIsUp = NO;
	while (!done)
	{
		NSEvent *event;
		NSPoint lastPoint = currentPoint;

		NSDate *endDate;

		// Set up timer for pop-up menu if we have one
		if ([self menu])
			endDate = [NSDate dateWithTimeIntervalSinceNow:0.6];
		else
			endDate = [NSDate distantFuture];

		event = [NSApp nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask)
								   untilDate:endDate
									  inMode:NSEventTrackingRunLoopMode
									 dequeue:YES];

		if (event)	// Mouse event
		{
			currentPoint = [event locationInWindow];

			// Send continueTracking.../stopTracking...
			if (trackContinously)
			{
				if (![self continueTracking:lastPoint at:currentPoint inView:controlView])
				{
					done = YES;
					[self stopTracking:lastPoint at:currentPoint inView:controlView mouseIsUp:mouseIsUp];
				}
				if ([self isContinuous])
				{
					[NSApp sendAction:[self action] to:[self target] from:controlView];
				}
			}

			mouseIsUp = ([event type] == NSLeftMouseUp);
			done = done || mouseIsUp;

			if (untilMouseUp)
			{
				result = mouseIsUp;
			}
			else
			{
				// Check if the mouse left our cell rect
				result = NSPointInRect([controlView convertPoint:currentPoint fromView:nil], cellFrame);
				if (!result)
					done = YES;
			}

			if (done && result && ![self isContinuous])
				[NSApp sendAction:[self action] to:[self target] from:controlView];

		}
		else	// Show menu
		{
			done = YES;
			result = YES;
			[self showMenuForEvent:theEvent controlView:controlView cellFrame:cellFrame];
		}
	}
	return result;
}

@end

@interface KBDelayedPopUpButton : NSButton
@end

@implementation KBDelayedPopUpButton

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]))
	{
		if (![[self cell] isKindOfClass:[KBDelayedPopUpButtonCell class]])
		{
			NSString *title = [self title];
			if (title == nil) title = @"";
			[self setCell:[[[KBDelayedPopUpButtonCell alloc] initTextCell:title] autorelease]];
			[[self cell] setControlSize:NSRegularControlSize];
		}
	}
	return self;
}

@end


@implementation MLKBPopUpToolbarItem

- (id)initWithItemIdentifier:(NSString *)ident
{
	if ((self = [super initWithItemIdentifier:ident]))
	{
		button = [[KBDelayedPopUpButton alloc] initWithFrame:NSMakeRect(0,0,32,32)];
		[button setButtonType:NSMomentaryChangeButton];
		[button setBordered:NO];
		[self setView:button];
		[self setMinSize:NSMakeSize(32,32)];
		[self setMaxSize:NSMakeSize(32,32)];
	}
	return self;
}

// Note that we make no assumptions about the retain/release of the toolbar item's view, just to be sure -
// we therefore retain our button view until we are dealloc'd.
- (void)dealloc
{
	[button release];
	[regularImage release];
	[smallImage release];
	[super dealloc];
}

- (KBDelayedPopUpButtonCell *)popupCell
{
	return [(KBDelayedPopUpButton *)[self view] cell];
}

- (void)setMenu:(NSMenu *)menu
{
	[[self popupCell] setMenu:menu];

	// Also set menu form representation - this is used in the toolbar overflow menu but also, more importantly, to display
	// a menu in text-only mode.
	NSMenuItem *menuFormRep = [[NSMenuItem alloc] initWithTitle:[self label] action:nil keyEquivalent:@""];
	[menuFormRep setSubmenu:menu];
	[self setMenuFormRepresentation:menuFormRep];
	[menuFormRep release];
}

- (NSMenu *)menu
{
	return [[self popupCell] menu];
}

- (void)setAction:(SEL)aSelector
{
	[[self popupCell] setAction:aSelector];
}

- (SEL)action
{
	return [[self popupCell] action];
}

- (void)setTarget:(id)anObject
{
	[[self popupCell] setTarget:anObject];
}

- (id)target
{
	return [[self popupCell] target];
}

- (void)setImage:(NSImage *)anImage
{
	[regularImage autorelease];
	[smallImage autorelease];

	// ML: I'm not particularly strict about using 32x32 icons, so I patched this to resize whatever icon you give it to 32x32

	regularImage = [anImage copy];
	[regularImage setScalesWhenResized:YES];
	[regularImage setSize:NSMakeSize(32, 32)];
	smallImage = [anImage copy];
	[smallImage setScalesWhenResized:YES];
	[smallImage setSize:NSMakeSize(24,24)];

	anImage = ([[self toolbar] sizeMode] == NSToolbarSizeModeSmall) ? smallImage : regularImage;

	[[self popupCell] setImage:anImage];
}

- (NSImage *)image
{
	return [[self popupCell] image];
}

- (void)setToolTip:(NSString *)theToolTip
{
	[[self view] setToolTip:theToolTip];
}

- (NSString *)toolTip
{
	return [[self view] toolTip];
}

- (void)validate
{
	// First, make sure the toolbar image size fits the toolbar size mode; there must be a better place to do this!
	NSToolbarSizeMode sizeMode = [[self toolbar] sizeMode];
	float imgWidth = (float) [[self image] size].width;

	if (sizeMode == NSToolbarSizeModeSmall && imgWidth != 24)
	{
		[[self popupCell] setImage:smallImage];
	}
	else if (sizeMode == NSToolbarSizeModeRegular && imgWidth == 24)
	{
		[[self popupCell] setImage:regularImage];
	}

	if ([[self toolbar] delegate])
	{
		BOOL enabled = YES;

		if ([[[self toolbar] delegate] respondsToSelector:@selector(validateToolbarItem:)])
			enabled = [(id)[[self toolbar] delegate] validateToolbarItem:self];

		else if ([[[self toolbar] delegate] respondsToSelector:@selector(validateUserInterfaceItem:)])
			enabled = [(id)[[self toolbar] delegate] validateUserInterfaceItem:self];

		[self setEnabled:enabled];
	}

	else if ([self action])
	{
		if (![self target])
			[self setEnabled:[[[[self view] window] firstResponder] respondsToSelector:[self action]]];

		else
			[self setEnabled:[[self target] respondsToSelector:[self action]]];
	}

	else
		[super validate];
}

// ML: added
- (void)setMenuOnly:(BOOL)to
{
	[[button cell] setMenuOnly:to];
}

@end
