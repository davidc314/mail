//
//  Account.h
//  Mail
//
//  Created by David Coninckx on 11.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

@interface Account : NSObject <NSCoding>

/** Nom du compte */
@property (strong) NSString  *name;

/** L'adresse email */
@property (strong,nonatomic) NSString  *mail;

/* @name IMAP */

/** Le nom d'utilisateur de la session IMAP */
@property (strong) NSString  *imapUsername;

/** Le mot de passe de la session IMAP */
@property (strong) NSString  *imapPassword;

/** L'adresse du serveur IMAP */
@property (strong) NSString  *imapHostname;

@property (assign) int  imapPort;
@property (assign) MCOConnectionType imapConnectionType;

/* @name SMTP */

@property (strong) NSString  *smtpUsername;
@property (strong) NSString  *smtpPassword;

@property (strong) NSString  *smtpHostname;
@property (assign) int  smtpPort;
@property (assign) MCOConnectionType smtpConnectionType;

@property (strong) MCOIMAPSession *imapSession;
@property (strong) MCOSMTPSession *smtpSession;

@property (strong) MCOMailProvider *provider;

@property (assign) BOOL sameAuth;
@property (strong) NSMutableArray *folders;

@property (assign) BOOL valid;

@property (assign) NSUInteger index;

@property (assign, nonatomic) NSUInteger nbUnread;

- (BOOL) isGMAIL;


- (void) fetchFolders;



@end
