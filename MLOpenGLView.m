#import "MLOpenGLView.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>

@interface MLOpenGLView (Private)

- (void)removeObserverIfNecessary;
- (void)surfaceNeedsUpdate:(NSNotification *)notification;

@end

@implementation MLOpenGLView

+ (NSOpenGLPixelFormat *)defaultPixelFormat
{
	NSOpenGLPixelFormatAttribute attribs[] = {
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute) 32,
		NSOpenGLPFAAlphaSize, (NSOpenGLPixelFormatAttribute) 8,
		NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute) 32,
		NSOpenGLPFAStencilSize, (NSOpenGLPixelFormatAttribute) 8,
		(NSOpenGLPixelFormatAttribute) 0
	};

	return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attribs] autorelease];
}

- (void)dealloc
{
	[self removeObserverIfNecessary];
	[self clearOpenGLContext];
	[pixelFormat release];

	[super dealloc];
}

- (void)removeObserverIfNecessary
{
	if (addedObserver) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewGlobalFrameDidChangeNotification object:self];

		addedObserver = NO;
	}
}

- (void)clearOpenGLContext
{
	if (openGLContext) {
		if ([openGLContext view] == self)
			[openGLContext clearDrawable];

		[openGLContext release];
		openGLContext = nil;
	}

	sharingOpenGLContext = nil;
}

- (void)setOpenGLContext:(NSOpenGLContext *)context
{
	[self clearOpenGLContext];
	openGLContext = [context retain];

	[self allocateGState];

	if (! addedObserver) {
		addedObserver = YES;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surfaceNeedsUpdate:) name:NSViewGlobalFrameDidChangeNotification object:self];
	}
}

- (NSOpenGLContext *)openGLContext
{
	return openGLContext;
}

- (NSOpenGLContext *)openGLContextCreateIfNecessary
{
	if (! openGLContext) {
		if (! [self createOpenGLContext])
			return nil;

		[openGLContext makeCurrentContext];
	}

	return openGLContext;
}

- (NSOpenGLContext *)createOpenGLContext
{
	return [self createOpenGLContextShareContext:nil];
}

- (NSOpenGLContext *)createOpenGLContextShareContext:(NSOpenGLContext *)shareContext
{
	[self clearOpenGLContext];

	NSOpenGLPixelFormat *usePixelFormat = [self pixelFormat];
	if (! usePixelFormat)
		return nil;

	NSOpenGLContext *newOpenGLContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:shareContext];

	if (! newOpenGLContext)
		return nil;

	[self setOpenGLContext:newOpenGLContext];
	sharingOpenGLContext = shareContext;
	
	[newOpenGLContext release]; // We've already retained it by calling setOpenGLContext.

	return newOpenGLContext;
}

- (NSOpenGLContext *)createPixelFormatAndOpenGLContextWithProperties:(const MLOpenGLViewProperties *)properties shareContext:(NSOpenGLContext *)shareContext
{
	int msaa = properties->msaa;
	if (msaa < 1)
		msaa = 1;

	for (; msaa; --msaa) {
		static const NSOpenGLPixelFormatAttribute endMarker = (NSOpenGLPixelFormatAttribute) 0;
		NSOpenGLPixelFormatAttribute attribs[] = {
			NSOpenGLPFADoubleBuffer,
			NSOpenGLPFAAccelerated,
			NSOpenGLPFANoRecovery,
			NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute) properties->colourBits,
			NSOpenGLPFAAlphaSize, (NSOpenGLPixelFormatAttribute) properties->alphaBits,
			NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute) properties->depthBits,
			NSOpenGLPFAStencilSize, (NSOpenGLPixelFormatAttribute) properties->stencilBits,
			msaa > 1 ? NSOpenGLPFAMultisample : endMarker,
			NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute) 1,
			NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute) msaa,
			endMarker
		};

		NSOpenGLPixelFormat *newPixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attribs] autorelease];

		if (! newPixelFormat)
			continue;

		[self setPixelFormat:newPixelFormat];
		NSOpenGLContext *newContext = [self createOpenGLContextShareContext:shareContext];

		if (newContext)
			return newContext;
	}

	return nil;
}

- (void)setPixelFormat:(NSOpenGLPixelFormat *)newPixelFormat
{
	[newPixelFormat retain];
	[pixelFormat release];
	pixelFormat = newPixelFormat;
}

- (NSOpenGLPixelFormat *)pixelFormat
{
	if (! pixelFormat)
		return [self createPixelFormat];

	return pixelFormat;
}

- (NSOpenGLPixelFormat *)createPixelFormat
{
	pixelFormat = [[[self class] defaultPixelFormat] retain];

	return pixelFormat;
}

- (void)getPixelFormatProperties:(MLOpenGLViewProperties *)properties
{
	GLint gotMSAA = 0;
	[pixelFormat getValues:&gotMSAA forAttribute:NSOpenGLPFASamples forVirtualScreen:0];
	properties->msaa = (int) gotMSAA;

	GLint gotColour;
	[pixelFormat getValues:&gotColour forAttribute:NSOpenGLPFAColorSize forVirtualScreen:0];
	properties->colourBits = (int) gotColour;

	GLint gotAlpha;
	[pixelFormat getValues:&gotAlpha forAttribute:NSOpenGLPFAColorSize forVirtualScreen:0];
	properties->alphaBits = (int) gotAlpha;

	GLint gotDepth;
	[pixelFormat getValues:&gotDepth forAttribute:NSOpenGLPFADepthSize forVirtualScreen:0];
	properties->depthBits = (int) gotDepth;

	GLint gotStencil;
	[pixelFormat getValues:&gotStencil forAttribute:NSOpenGLPFAStencilSize forVirtualScreen:0];
	properties->stencilBits = (int) gotStencil;
}

- (void)lockFocus
{
	NSOpenGLContext *context = [self openGLContextCreateIfNecessary];

	[super lockFocus];

	if ([context view] != self)
		[context setView:self];

	[context makeCurrentContext];
}

- (void)surfaceNeedsUpdate:(NSNotification *)notification
{
	[self update];
}

- (void)update
{
	if ([openGLContext view] == self)
		[openGLContext update];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect bounds = [self bounds];
	[[self openGLContextCreateIfNecessary] makeCurrentContext];
	glViewport(0, 0, (GLint) bounds.size.width, (GLint) bounds.size.height);
	// If you get orange then you know MLOpenGLView's drawRect is being called.
	glClearColor(1.0f, 0.5f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	[self flushBuffer];
}

- (void)flushBuffer
{
	glFlush();
	[[self openGLContext] flushBuffer];
}

@end
