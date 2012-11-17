#import <Cocoa/Cocoa.h>

typedef struct MLOpenGLViewProperties {
	int colourBits;
	int alphaBits;
	int depthBits;
	int stencilBits;
	int msaa;
} MLOpenGLViewProperties;

/// Replacement for NSOpenGLView that supports MSAA.
@interface MLOpenGLView : NSView {
	NSOpenGLPixelFormat *pixelFormat;
	NSOpenGLContext *openGLContext;
	NSOpenGLContext *sharingOpenGLContext;
	BOOL addedObserver;
}

/// Explicitly set the pixel format to use. This must be done before creating the OpenGL context.
- (void)setPixelFormat:(NSOpenGLPixelFormat *)newPixelFormat;

/// Returns the pixel format. If one hasn't already been set or created, createPixelFormat is called.
- (NSOpenGLPixelFormat *)pixelFormat;

/// Derived classes can override this to create their own pixel format. If not, a default pixel format is used.
- (NSOpenGLPixelFormat *)createPixelFormat;

/// Release the current OpenGL context.
- (void)clearOpenGLContext;

/// Explicitly set an NSOpenGLContext to use.
- (void)setOpenGLContext:(NSOpenGLContext *)context;

/// Returns our OpenGL context, or nil if it hasn't been created.
- (NSOpenGLContext *)openGLContext;

/// Returns our OpenGL context. If we don't yet have one, createOpenGLContext is called.
- (NSOpenGLContext *)openGLContextCreateIfNecessary;

/// Create an OpenGL context using the pixel format returned by pixelFormat.
- (NSOpenGLContext *)createOpenGLContext;

/// Explicitly create an OpenGL context that shares its lists with another pre-existing OpenGL context. You can call this with shareContext is nil, which is the same as calling createOpenGLContext.
- (NSOpenGLContext *)createOpenGLContextShareContext:(NSOpenGLContext *)shareContext;

/// Creates a pixel format and an OpenGL context. If necessary, loops until a supported MSAA setting is found.
- (NSOpenGLContext *)createPixelFormatAndOpenGLContextWithProperties:(const MLOpenGLViewProperties *)properties shareContext:(NSOpenGLContext *)shareContext;

/// Returns the properties of our pixel format. This works even if createPixelFormatAndOpenGLContextWithProperties wasn't used.
- (void)getPixelFormatProperties:(MLOpenGLViewProperties *)properties;

- (void)update;

/// Call this from your drawRect to display the back buffer.
- (void)flushBuffer;

@end
