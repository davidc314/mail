//
//  BodyTextView.m
//  Mail
//
//  Created by David Coninckx on 13.05.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import "BodyTextView.h"

@implementation BodyTextView

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
	
    // Drawing code here.
}
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}
- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    if([self.delegate respondsToSelector:@selector(dropAttachment:)]) {
        [self.delegate dropAttachment:sender];
    }
    
    
    return NO;
}
@end
