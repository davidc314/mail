//
//  MessageRowView.m
//  Mail
//
//  Created by David Coninckx on 31.03.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import "MessageRowView.h"

@implementation MessageRowView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSRect barRect = NSMakeRect(0, 0, 3, NSHeight(self.bounds));
    [[NSColor blackColor] set];
    [NSBezierPath fillRect:barRect];
}

@end
