//
//  Message.h
//  Mail
//
//  Created by Informatique on 06.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

#import "Account.h"
#import "Folder.h"

/** Modèle representant un message */
@interface Message : NSObject

/** Flags */
@property (assign) MCOMessageFlag flags;

/** ID unique */
@property (assign) NSInteger uid;

/** Date d'expédition */
@property (strong) NSDate *date;

/** Expéditeur */
@property (strong) NSString  *from;

/** Destinataires */
@property (strong) NSArray  *to;

/** Destinataires copies */
@property (strong) NSArray  *cc;

/** Destinataires copies cachées*/
@property (strong) NSArray  *bcc;

/** Sujet */
@property (strong) NSString  *subject;

/** Corp */
@property (strong) NSString  *htmlBody;

/** Pièces jointes */
@property (strong) NSMutableArray *attachments;

/** Contient des pièces jointes */
@property (assign) BOOL hasAttachments;

/** Répondu ? */
@property (assign) BOOL replied;

/** Transmis */
@property (assign) BOOL forwarded;

/** Non-lus */
@property (assign, nonatomic) BOOL unread;

/** Récupère et parse le contenu du message
 
 @param folder Le dossier dans lequel se trouve le message
 @param account Le compte associé au message
 @param handler callback
 
*/
- (void)fetchBodyForFolder:(Folder *)folder account:(Account *)account completion:(void (^)(NSString *, NSMutableArray *))handler;

/** Récupère et parse le contenu du message
 
 @param msg Le message retourné par la librairie
 
 @return Une instance initialisée de la classe Message
 
*/
- (id)initWithMCOIMAPMessage:(MCOIMAPMessage *)msg;

/** Initialise un nouveau message à envoyé
 
 @param to Le ou les destinataires
 @param cc Le ou les destinataires des copies
 @param bcc Le ou les destinataires des copies cachées
 @param subject Le sujet
 @param body Le contenu du message
 
 @return Le message prêt à être envoyé
 */
- (id)initBuildMessageWithTo: (NSArray *)to CC:(NSArray *)cc BCC:(NSArray *)bcc Subject:(NSString *)subject Body:(NSString *)body;

/*!
 Envoie un message correctement instancié
 */
- (void)sendMessage;

@end
