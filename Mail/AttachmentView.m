//
//  AttachmentView.m
//  attachmentsCollectionView
//
//  Created by Informatique on 17.03.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import "AttachmentView.h"



@implementation AttachmentView

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
    
    if (self.selected) {
        [[NSColor selectedControlColor] set];
        NSRectFill(self.bounds);
    }
}

-(void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    
    if (theEvent.clickCount > 1)
    {
        if([self.delegate respondsToSelector:@selector(doubleClick:)]) {
            [self.delegate doubleClick:self];
        }
    }
}
-(void) rightMouseDown:(NSEvent *)theEvent
{
    if([self.delegate respondsToSelector:@selector(rightClicked:event:)]) {
        [self.delegate rightClicked:self event:theEvent];
    }
}

@end
