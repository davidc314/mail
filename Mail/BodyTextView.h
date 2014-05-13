//
//  BodyTextView.h
//  Mail
//
//  Created by David Coninckx on 13.05.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol BodyTextViewDelegate <NSObject>

- (void) dropAttachment:(id)sender ;

@end

@interface BodyTextView : NSTextView <NSDraggingDestination>
@property IBOutlet id delegate;
@end
