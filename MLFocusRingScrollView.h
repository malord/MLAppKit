#import <Cocoa/Cocoa.h>

/// Encapsulates the focus ring drawing code by Nicholas Riley, posted on cocoadev and available at
/// http://lists.apple.com/archives/cocoa-dev/2002/Mar/msg01620.html
/// Change your NSScrollView's class to MLFocusRingScrollView in Interface Builder.
@interface MLFocusRingScrollView : NSScrollView {
	NSResponder *_mlLastResponder;
	BOOL _mlShouldDrawFocusRing;
}

@end
