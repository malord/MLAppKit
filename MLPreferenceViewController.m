#import "MLPreferenceViewController.h"

@implementation MLPreferenceViewController

- (id)init
{
	self = [super init];

	return self;
}

- (void)dealloc
{
	[title release];
	[ident release];
	[image release];

	[view release];

	[super dealloc];
}

- (NSView *)view
{
	return view;
}

- (NSString *)title
{
	return title;
}

- (void)setTitle:(NSString *)newTitle
{
	[newTitle retain];
	[title release];
	title = newTitle;
}

- (NSString *)identifier
{
	return ident;
}

- (void)setIdentifier:(NSString *)newIdentifier
{
	[newIdentifier retain];
	[ident release];
	ident = newIdentifier;
}

- (BOOL)loadViewNibNamed:(NSString *)nibName
{
	if (! [NSBundle loadNibNamed:nibName owner:self])
		return NO;

	return YES;
}

- (NSImage *)image
{
	return image;
}

- (void)setImage:(NSImage *)anImage
{
	[anImage retain];
	[image release];
	image = anImage;
}

- (void)setPreferencesPanelWindow:(NSWindow *)window
{
	preferencesPanelWindow = window;
}

- (NSWindow *)preferencesPanelWindow
{
	return preferencesPanelWindow;
}

- (void)activated
{
}

- (BOOL)isResizable
{
	return NO;
}

@end
