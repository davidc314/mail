//
//  AttachmentView.m
//  attachmentsCollectionView
//
//  Created by Coninckx David on 17.03.14.
//  Copyright (c) 2014 Coninckx David. All rights reserved.
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

/* Colore en bleu un élément selectionné */
- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    if (self.selected) {
        [[NSColor selectedControlColor] set];
        NSRectFill(self.bounds);
    }
}


/* Double clique gauche */
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

/* Clique droit */
-(void) rightMouseDown:(NSEvent *)theEvent
{
    if([self.delegate respondsToSelector:@selector(rightClicked:event:)]) {
        [self.delegate rightClicked:self event:theEvent];
    }
}

@end
