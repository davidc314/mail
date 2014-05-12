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

/** Controlleur de l'interface de visualisation du contenu d'un message */
@interface MessageDetail : NSWindowController <NSCollectionViewDelegate>

/** Champ HTML pour le contenu du message */
@property (weak) IBOutlet WebView *body;

/** Vues pour les pièces jointes */
@property (weak) IBOutlet NSCollectionView *attachmentCollectionView;

/** Menu contextuel pour une pièce jointe */
@property (strong) IBOutlet NSMenu *attachmentContextMenu;

/** Message représenté */
@property (strong) Message *message;

/** Contenu en cours de récupération ? */
@property (assign) BOOL fetching;


/** Initialisation de l'interface pour un message donné
 @param message Le message à afficher
 @param folder Le dossier dans lequel se trouve le message
 @param account Le compte auquel appartient le message
 
 @return L'interface MessageDetail correctement initilialisée selon l'IB.
 */
-(id)initWithMessage:(Message *)message folder:(Folder *)folder account:(Account *)account;


@end
