#import "MLAboutPanelController.h"

@implementation MLAboutPanelController

- (id)initWithAppTitle:(NSString *)appTitle
{
	return [self initWithAppTitle:appTitle buttonTitle:nil buttonDelegate:nil buttonSelector:NULL];
}

- (id)initWithAppTitle:(NSString *)appTitle buttonTitle:(NSString *)buttonTitle buttonDelegate:(id)buttonDelegate buttonSelector:(SEL)buttonSelector
{
	self = [super initWithWindowNibName:@"AboutPanel"];
	if (! self)
		return nil;
		
	_appTitle = [appTitle retain];
	_buttonTitle = [buttonTitle retain];
	
	_buttonDelegate = buttonDelegate;
	_buttonSelector = buttonSelector;

	return self;
}

- (void)dealloc
{
	[_appTitle release];
	[_buttonTitle release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	[[self window] center];

	//[title setStringValue:[[NSProcessInfo processInfo] processName]];
	[title setStringValue:_appTitle];
	
	if (_buttonTitle)
		[button setTitle:_buttonTitle];
	else
		[button setHidden:YES];

	NSBundle *mainBundle = [NSBundle mainBundle];

	NSString *versionPrefix = [version stringValue];
	NSString *bundleVersionString = [[mainBundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *bundleVersion = [[mainBundle infoDictionary] objectForKey:@"CFBundleVersion"];

	if ([bundleVersionString length]) {
		NSString *formattedVersion = [NSString stringWithFormat:@"%@ (%@)", bundleVersionString, bundleVersion];
		[version setStringValue:[versionPrefix stringByAppendingString:formattedVersion]];
	} else {
		[version setStringValue:[versionPrefix stringByAppendingString:bundleVersion]];
	}

	NSString *bundleCopyright = [[mainBundle localizedInfoDictionary] objectForKey:@"NSHumanReadableCopyright"];
	[copyright setStringValue:bundleCopyright];
}

- (IBAction)buttonClicked:(id)sender
{
	[_buttonDelegate performSelector:_buttonSelector withObject:self];
}

@end
