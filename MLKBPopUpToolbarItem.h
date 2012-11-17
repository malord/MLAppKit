//
//  KBPopUpToolbarItem.h
//  --------------------
//
//  Created by Keith Blount on 14/05/2006.
//  Copyright 2006 Keith Blount. All rights reserved.
//
//	Provides a toolbar item that performs its given action if clicked, or displays a pop-up menu
//	(if it has one) if held down for over half a second.
//
// MLKBPopUpToolbarItem extends KBPopUpToolbarItem so that items with popup menus can display the menu immediately,
// instead of after a short delay. Just call setMenuOnly to enable.
//

#import <Cocoa/Cocoa.h>
@class KBDelayedPopUpButton;

@interface MLKBPopUpToolbarItem : NSToolbarItem
{
	KBDelayedPopUpButton *button;
	NSImage *smallImage;
	NSImage *regularImage;
}
- (void)setMenu:(NSMenu *)menu;
- (NSMenu *)menu;

// ML: added
- (void)setMenuOnly:(BOOL)to;
@end
