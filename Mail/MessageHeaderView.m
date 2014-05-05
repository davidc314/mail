//
//  MessageHeaderView.m
//  Mail
//
//  Created by David Coninckx on 27.03.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import "MessageHeaderView.h"

@implementation MessageHeaderView

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
    [[NSColor whiteColor] set];
    NSRectFill(NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height));
    
    [[NSColor grayColor] set];
    NSRectFill(NSMakeRect(10, 0, self.frame.size.width-20, 1));
    
	[super drawRect:dirtyRect];
    
}

@end
