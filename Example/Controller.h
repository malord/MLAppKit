#import <Cocoa/Cocoa.h>

@class MLPreferencesPanelController;

@interface Controller : NSObject
{
	MLPreferencesPanelController *preferencesPanelController;
}

- (IBAction)preferences:(id)sender;

@end
