//
//  NewMessage.h
//  Mail
//
//  Created by David Coninckx on 08.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AttachmentCollectionView.h"
#import "RecipientTokenField.h"
@class Account;

/** Controlleur de l'interface de création d'un message */
@interface NewMessage : NSWindowController <NSCollectionViewDelegate,NSUserNotificationCenterDelegate>

/** Champ de saisie pour [Message to] */
@property (weak) IBOutlet RecipientTokenField *to;

/** Champ de saisie pour [Message subject] */
@property (weak) IBOutlet NSTextField *subject;

/** Champ de saisie pour [Message htmlBody] */
@property (strong) IBOutlet NSTextView *body;

/** Le compte à partir duquel on envoie le message */
@property (strong) Account *selectedAccount;

/** Tableau des pièces jointes contenues dans le message */
@property (strong) NSMutableArray *attachments;

/** Les comptes à lister dans le menu déroulant */
@property (strong) NSArray *accounts;

/** Controlleur pour le tableau des comptes */
@property (strong) IBOutlet NSArrayController *accountsArrayController;

/** Vue personnalisée pour représenter les pièces jointes */
@property (weak) IBOutlet AttachmentCollectionView *attachmentsCollectionView;

/** Menu contextuel pour une pièce jointe */
@property (strong) IBOutlet NSMenu *attachmentContextMenu;

@end
