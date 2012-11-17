#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
extern "C" {
#endif

void NeedMLIsTextFieldFirstResponder(void);

#ifdef __cplusplus
}
#endif

@interface NSTextField (MLIsTextFieldFirstResponder)

/// Returns YES if this NSTextField is the first responder for its window.
- (BOOL)isFirstResponderForWindow;

@end
