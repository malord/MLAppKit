MLAppKit
========

A collection of useful Cocoa classes.

## MLPreferencesPanelController

Provides a Mac style Preferences panel, where the toolbar contains tabs which select between multiple pages. An example project that demonstrates this is included.

![Preferences Panel](https://github.com/malord/MLAppKit/raw/master/Screenshots/PreferencesPanel.png)

## MLOpenGLView

Replacement for NSOpenGLView that supports MSAA and has easier to use OpenGL context sharing.

## MLLogWindowController

Provides a thread safe log window, with support for colourised output.

## MLFocusRingScrollView

Use this class in place of NSScrollView to draw a focus ring around the scroll view when one of its subviews is the first responder.

## MLAboutPanelController

A custom About box.

## MLKBPopUpToolbarItem

Extends Keith Blount's KBPopUpToolbarItem to support toolbar items which present a menu as soon as they're tapped, rather than after a delay.

## MLIsTextFieldFirstResponder

Extends NSTextField with a method `isFirstResponderForWindow`, which works out whether an NSTextField is its window's first responder, taking in to account the field editor.

