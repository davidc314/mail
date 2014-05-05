//
//  MessageDetail.h
//  Mail
//
//  Created by Informatique on 05.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "Message.h"

@interface MessageDetail : NSWindowController

@property (weak) IBOutlet WebView *body;

@property (weak) IBOutlet NSCollectionView *attachmentCollectionView;

@property (strong) IBOutlet NSMenu *attachmentContextMenu;

@property (strong) Message *message;

@property (assign) BOOL fetching;

- (id) initWithMessage:(Message *)message folder:(Folder *)folder account:(Account *)account;


@end
