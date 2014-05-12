//
//  NewMessage.h
//  Mail
//
//  Created by David Coninckx on 08.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** Controlleur de l'interface de création d'un message */
@interface NewMessage : NSWindowController

/** Champ de saisie pour [Message to] */
@property (weak) IBOutlet NSTokenField *to;

/** Champ de saisie pour [Message cc] */
@property (weak) IBOutlet NSTokenField *cc;

/** Champ de saisie pour [Message bcc] */
@property (weak) IBOutlet NSTokenField *bcc;

/** Champ de saisie pour [Message subject] */
@property (weak) IBOutlet NSTextField *subject;

/** Champ de saisie pour [Message htmlBody] */
@property (strong) IBOutlet NSTextView *body;

/** Tableau des pièces jointes contenues dans le message */
@property (strong) NSMutableArray *attachments;
@property (strong) NSArray *accounts;

@property (strong) IBOutlet NSArrayController *arrayController;
@property (weak) IBOutlet NSCollectionView *collectionView;
@end
