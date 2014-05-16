//
//  NewMessage.h
//  Mail
//
//  Created by David Coninckx on 08.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AttachmentCollectionView.h"
@class Account;

/** Controlleur de l'interface de création d'un message */
@interface NewMessage : NSWindowController <NSCollectionViewDelegate>

/** Champ de saisie pour [Message to] */
@property (weak) IBOutlet NSTokenField *to;

/** Champ de saisie pour [Message subject] */
@property (weak) IBOutlet NSTextField *subject;

/** Champ de saisie pour [Message htmlBody] */
@property (strong) IBOutlet NSTextView *body;

@property (strong) Account *selectedAccount;

/** Tableau des pièces jointes contenues dans le message */
@property (strong) NSMutableArray *attachments;
@property (strong) NSArray *accounts;
@property (weak) IBOutlet NSView *ccFieldsView;

@property (strong) IBOutlet NSArrayController *arrayController;
@property (weak) IBOutlet AttachmentCollectionView *attachmentCollectionView;
@property (strong) IBOutlet NSMenu *attachmentContextMenu;

@end
