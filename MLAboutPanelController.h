#import <Cocoa/Cocoa.h>

/// A custom About box.
@interface MLAboutPanelController : NSWindowController {
	IBOutlet NSTextField *title;
	IBOutlet NSTextField *version;
	IBOutlet NSTextField *copyright;
	IBOutlet NSButton *button;

	NSString *_appTitle;
	NSString *_buttonTitle;

	id _buttonDelegate;
	SEL _buttonSelector;
}

- (id)initWithAppTitle:(NSString *)appTitle buttonTitle:(NSString *)buttonTitle buttonDelegate:(id)buttonDelegate buttonSelector:(SEL)buttonSelector;

- (id)initWithAppTitle:(NSString *)appTitle;

- (IBAction)buttonClicked:(id)sender;

@end
