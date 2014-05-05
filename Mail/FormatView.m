//
//  FormatView.m
//  attachmentsCollectionView
//
//  Created by Informatique on 17.03.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import "FormatView.h"

@implementation FormatView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	NSRect frameRect = [self bounds];
    
    NSRect newRect = NSMakeRect(frameRect.origin.x+.5, frameRect.origin.y+.5, frameRect.size.width-1, frameRect.size.height-1);
    //newRect = NSOffsetRect(newRect, -.5, .5);
    // Drawing code here.
    NSBezierPath * bezierPath = [NSBezierPath bezierPathWithRoundedRect:newRect xRadius:3 yRadius:3];
    //[[NSGraphicsContext currentContext] setShouldAntialias:NO];
    NSColor *lightGray = [NSColor colorWithDeviceWhite:180/255.0 alpha:1];
    
    //NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:lightGray endingColor:darkGray];
    //[gradient drawInBezierPath:bezierPath angle:-90];
    [bezierPath setLineWidth:.5];
    [[NSColor blackColor] set];
    [bezierPath stroke];
    [lightGray set];
    [bezierPath fill];
    // Drawing code here.
}

@end
