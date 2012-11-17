#import "MLMenuSearching.h"

@implementation NSMenu (MLMenuSearching)

- (NSMenu *)findSubmenuWithAction:(SEL)actionSelector
{
	NSArray *itemArray = [self itemArray];
	
	for (NSUInteger i = 0; i != [itemArray count]; ++i) {
		NSMenuItem *item = [itemArray objectAtIndex:i];
		
		if ([item action] == actionSelector)
			return self;
			
		if ([item hasSubmenu]) {
			NSMenu *found = [[item submenu] findSubmenuWithAction:actionSelector];
			if (found)
				return found;
		}
	}
	
	return nil;
}

@end
