//
//  Account.h
//  Mail
//
//  Created by David Coninckx on 11.02.14.
//  Copyright (c) 2014 Coninckx David. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>



/** Modèle representant un compte */
@interface Account : NSObject <NSCoding>

/** @name Informations générales */

/** Nom du compte */
@property (strong) NSString  *name;

/** L'adresse email */
@property (strong,nonatomic) NSString  *mail;

/** @name Serveur IMAP */

/** Le nom d'utilisateur */
@property (strong) NSString  *imapUsername;

/** Le mot de passe */
@property (strong) NSString  *imapPassword;

/** L'adresse du serveur */
@property (strong) NSString  *imapHostname;

/** Le numéro de port */
@property (assign) int  imapPort;

/** Le type de connection */
@property (assign) MCOConnectionType imapConnectionType;

/** @name Serveur SMTP */

/** Le nom d'utilisateur */
@property (strong) NSString  *smtpUsername;

/** Le mot de passe */
@property (strong) NSString  *smtpPassword;

/** L'adresse du serveur */
@property (strong) NSString  *smtpHostname;

/** Le numéro de port */
@property (assign) int  smtpPort;

/** Le type de connection */
@property (assign) MCOConnectionType smtpConnectionType;

/** @name Autres propriétés */

/** Session IMAP */
@property (strong) MCOIMAPSession *imapSession;

/** Session SMTP */
@property (strong) MCOSMTPSession *smtpSession;

/** Fournisseur du compte */
@property (strong) MCOMailProvider *provider;

/** Informations identiques pour les deux sessions (nom d'utilisateur/mot de passe) */
@property (assign) BOOL sameAuth;

/** Les dossiers IMAP */
@property (strong) NSMutableArray *folders;

/** La validé du compte (IMAP/SMTP) */
@property (assign) BOOL valid;

/** L'index du compte pour le trier */
@property (assign) NSUInteger index;

/** Le nombre de messages non-lus pour l'ensemble des dossiers */
@property (assign, nonatomic) NSUInteger nbUnread;


/** @name Méthodes */

/** Récupérations des dossiers */
- (void) fetchFolders;



@end
