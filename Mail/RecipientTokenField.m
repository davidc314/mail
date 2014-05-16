//
//  RecipientTokenField.m
//  Mail
//
//  Created by David Coninckx on 16.05.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import "RecipientTokenField.h"

@implementation RecipientTokenField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Initialization code here.
        NSCharacterSet *tokenizingCharSet = [NSCharacterSet characterSetWithCharactersInString:@";"];
        [self setTokenizingCharacterSet:tokenizingCharSet];
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void) textDidChange:(NSNotification *)notification {
    self.empty = self.stringValue.length>0;
}

@end
