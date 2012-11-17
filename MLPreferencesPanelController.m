#import "MLPreferencesPanelController.h"
#import "MLPreferenceViewController.h"

@implementation MLPreferencesPanelController

- (id)init
{
	self = [super initWithWindowNibName:@"PreferencesPanel"];

	itemsMap = [[NSMutableDictionary alloc] init];
	itemsKeys = [[NSMutableArray alloc] init];

	return self;
}

- (void)dealloc
{
	[itemsMap release];
	[itemsKeys release];

	[super dealloc];
}

- (void)addViewController:(MLPreferenceViewController *)viewController
{
	[itemsMap setObject:viewController forKey:[viewController identifier]];
	[itemsKeys addObject:[viewController identifier]];
}

- (void)awakeFromNib
{
	toolbar = [[NSToolbar alloc] initWithIdentifier:@"PreferencesPanelToolbar"];
	[toolbar setDelegate:(id)self]; // cast to id to prevent warning about not implementing NSToolbarDelegate on 10.6
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setAutosavesConfiguration:NO];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	[[self window] setToolbar:toolbar];
	[[self window] center];
	[[self window] setShowsResizeIndicator:NO];

	[self activateViewWithIdentifier:[itemsKeys objectAtIndex:0]];
}

- (void)highlightToolbarItemWithIdentifier:(NSString *)ident
{
	[toolbar setSelectedItemIdentifier:ident];
}

- (BOOL)activateViewWithIdentifier:(NSString *)viewName
{
	MLPreferenceViewController *viewController = [itemsMap objectForKey:viewName];

	if (! viewController)
		return NO;

	[viewController setPreferencesPanelWindow:[self window]];

	NSView *newView = [viewController view];

	if (currentView) {
		if (currentView == newView)
			return YES;

		[currentView removeFromSuperview];
	}

	NSView *parentView = [[self window] contentView];

	NSRect desiredBounds = [newView bounds];

	NSRect frameSize = [[self window] frameRectForContentRect:desiredBounds];
	NSRect currentFrame = [[self window] frame];

	NSRect frameRect = frameSize;
	frameRect.origin.x = currentFrame.origin.x;
	frameRect.origin.y = currentFrame.origin.y + currentFrame.size.height - frameSize.size.height;

	[[self window] setShowsResizeIndicator:[viewController isResizable]];
	[[self window] setFrame:frameRect display:YES animate:[[self window] isVisible]];

	[parentView addSubview:newView];
	[parentView setNextKeyView:newView];
	[newView setFrame:[parentView bounds]];

	currentView = newView;
	[viewController activated];

	[[self window] recalculateKeyViewLoop];

	[self highlightToolbarItemWithIdentifier:viewName];

	return YES;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return itemsKeys;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
	return itemsKeys;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return itemsKeys;
}

- (BOOL)validateToolbarItem:(NSToolbarItem*)toolbarItem
{
	return YES;
}

- (IBAction)toolbarButtonClicked:(id)sender
{
	NSToolbarItem *toolbarItem = sender;

	[self activateViewWithIdentifier:[toolbarItem itemIdentifier]];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	MLPreferenceViewController *viewController = [itemsMap objectForKey:itemIdentifier];

	if (! viewController)
		return nil;

	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	[item autorelease];
	[item setLabel:[viewController title]];
	[item setTarget:self];
	[item setAction:@selector(toolbarButtonClicked:)];
	[item setImage:[viewController image]];

	return item;
}

@end
