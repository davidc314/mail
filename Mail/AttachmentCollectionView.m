//
//  AttachmentCollectionView.m
//  Mail
//
//  Created by David Coninckx on 15.05.14.
//  Copyright (c) 2014 Coninckx David. All rights reserved.
//

#import "AttachmentCollectionView.h"

@implementation AttachmentCollectionView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

/* Ecrit un "drop attachment here" au centre de la vue lorsqu'elle est vide */
- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    if(!self.hasAttachment) {
        NSString *message = @"Drop attachment here";
        
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        [attrs setObject:[NSFont boldSystemFontOfSize:13] forKey:NSFontAttributeName];
        [attrs setObject:[NSColor lightGrayColor] forKey:NSForegroundColorAttributeName];
        
        NSUInteger xPos = self.frame.size.width/2 - [message sizeWithAttributes:attrs].width/2;
        NSUInteger yPos = self.frame.size.height/2 - [message sizeWithAttributes:attrs].height/2;;
        
        [message drawAtPoint:NSMakePoint(xPos, yPos) withAttributes:attrs];
    }
    
    // Drawing code here.
}

/* Touche delete ou backspace pressée pour supprimer un ou plusieurs éléments */
- (void)keyDown:(NSEvent *)theEvent
{
    if([[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSDeleteCharacter
       || [[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSDeleteFunctionKey) {
        if([self.delegate respondsToSelector:@selector(deleteAttachments)]) {
            [(id<AttachmentCollectionViewDelegate>)self.delegate deleteAttachments];
        }
    }
}
@end
