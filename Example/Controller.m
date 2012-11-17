#import "Controller.h"
#import <MLAppKit/MLPreferencesPanelController.h>
#import <MLAppKit/MLPreferenceViewController.h>

@interface Controller (Private)

- (MLPreferenceViewController *)createGeneralPreferencesController;
- (MLPreferenceViewController *)createProjectPreferencesController;

@end

@implementation Controller

- (void)dealloc
{
	[preferencesPanelController release];

	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[self performSelector:@selector(preferences:) withObject:self afterDelay:0.1];
}

- (IBAction)preferences:(id)sender
{
	if (! preferencesPanelController)
	{
		preferencesPanelController = [[MLPreferencesPanelController alloc] init];

		[preferencesPanelController addViewController:[self createGeneralPreferencesController]];
		[preferencesPanelController addViewController:[self createProjectPreferencesController]];
	}

	[preferencesPanelController showWindow:self];
}

- (MLPreferenceViewController *)createGeneralPreferencesController
{
	// Instead of using MLPreferenceViewController you'd usually want to subclass it. Then, in the xib file, use your
	// class as the File's Owner and hook up any outlets/actions you need.
	MLPreferenceViewController *general = [[MLPreferenceViewController alloc] init];

	[general setTitle:@"General"];
	[general setIdentifier:@"general"];
	[general loadViewNibNamed:@"GeneralPreferences"];
	[general setImage:[NSImage imageNamed:@"GeneralPreferences"]];

	return [general autorelease];
}

- (MLPreferenceViewController *)createProjectPreferencesController
{
	MLPreferenceViewController *projects = [[MLPreferenceViewController alloc] init];

	[projects setTitle:@"Projects"];
	[projects setIdentifier:@"projects"];
	[projects loadViewNibNamed:@"ProjectPreferences"];
	[projects setImage:[NSImage imageNamed:@"ProjectPreferences"]];

	return [projects autorelease];
}

@end
