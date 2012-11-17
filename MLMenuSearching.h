#import <Cocoa/Cocoa.h>

@interface NSMenu (MLMenuSearching)

/// Returns the menu that contains the item.
- (NSMenu *)findSubmenuWithAction:(SEL)selector;

@end
