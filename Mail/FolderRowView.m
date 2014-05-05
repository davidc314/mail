//
//  FolderRowView.m
//  Mail
//
//  Created by David Coninckx on 09.04.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import "FolderRowView.h"

@implementation FolderRowView

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
    [self setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
}


@end
