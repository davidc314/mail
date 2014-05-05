//
//  ACSearchFieldCell.m
//  AppCleaner
//
//  Created by Julien Ramseier on 23.12.13.
//  Copyright (c) 2013 FreeMacSoft. All rights reserved.
//

#import "SearchFieldCell.h"

@implementation SearchFieldCell {
    NSImage *searchImg;
}

- (id)init
{
    self = [super init];
    if (self) {
        searchImg = [NSImage imageNamed:@"search"];
        
        NSButtonCell *searchCell = [[NSButtonCell alloc] initImageCell:searchImg];
        [searchCell setImageDimsWhenDisabled:NO];
        [searchCell setEnabled:NO];
        [searchCell setBordered:NO];
        [self setSearchButtonCell:searchCell];
        
        self.drawsBackground = YES;
        self.backgroundColor = [NSColor colorWithCalibratedWhite:252/255.0 alpha:1.0];
        self.focusRingType = NSFocusRingTypeNone;
        self.font = [NSFont fontWithName:@"Helvetica Neue Light" size:15.0];
    }
    return self;
}

- (NSRect)searchTextRectForBounds:(NSRect)rect
{
    NSRect textRect = [super searchTextRectForBounds:rect];
    textRect.origin.x += 12;
    textRect.size.width -= 12;
    return textRect;
}

- (NSRect)searchButtonRectForBounds:(NSRect)rect
{
    NSRect searchButtonRect = [super searchButtonRectForBounds:rect];
    searchButtonRect.origin.x += 6;
    return searchButtonRect;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSBezierPath *cellPath = [NSBezierPath bezierPathWithRect:cellFrame];
    // Fill background
    [[NSColor colorWithCalibratedWhite:252/255.0 alpha:1.0] set];
    [cellPath fill];
    
    // Draw top and bottom borders
    [[NSColor lightGrayColor] set];
    //NSRectFill(NSMakeRect(0, 0, NSWidth(cellFrame), 1));
    NSRectFill(NSMakeRect(0, NSHeight(cellFrame)-1, NSWidth(cellFrame), 1));
    
    if ([self showsFirstResponder]) {
        // Light blue background when selected
        [[NSColor colorWithDeviceRed:60/255.0 green:156/255.0 blue:250/255.0 alpha:0.05] set];
        [cellPath fill];
        
        [self.searchButtonCell setImage:searchImg];
    } else {
        [self.searchButtonCell setImage:searchImg];
    }
    [self drawInteriorWithFrame:cellFrame inView:controlView];
}


- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView
               editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{
    [super editWithFrame:aRect
                  inView:controlView editor:textObj
                delegate:anObject
                   event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView
                 editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
    [super selectWithFrame:aRect
                    inView:controlView
                    editor:textObj
                  delegate:anObject
                     start:selStart
                    length:selLength];
}

@end
