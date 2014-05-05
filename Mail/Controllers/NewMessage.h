//
//  NewMessage.h
//  Mail
//
//  Created by David Coninckx on 08.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NewMessage : NSWindowController

@property (weak) IBOutlet NSTokenField *to;
@property (weak) IBOutlet NSTokenField *cc;
@property (weak) IBOutlet NSTokenField *bcc;
@property (weak) IBOutlet NSTextField *subject;
@property (strong) IBOutlet NSTextView *body;

@property (strong) NSMutableArray *attachments;
@property (strong) IBOutlet NSArrayController *arrayController;
@property (weak) IBOutlet NSCollectionView *collectionView;
@end
