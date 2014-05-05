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

@property (strong) NSString  *name;
@property (strong,nonatomic) NSString  *mail;

@property (strong) NSString  *imapUsername;
@property (strong) NSString  *imapPassword;

@property (strong) NSString  *imapHostname;
@property (assign) int  imapPort;
@property (assign) MCOConnectionType imapConnectionType;

@property (strong) NSString  *smtpUsername;
@property (strong) NSString  *smtpPassword;

@property (strong) NSString  *smtpHostname;
@property (assign) int  smtpPort;
@property (assign) MCOConnectionType smtpConnectionType;

@property (strong) MCOIMAPSession *imapSession;
@property (strong) MCOSMTPSession *smtpSession;

@property (assign) BOOL sameAuth;
@property (strong) NSMutableArray *folders;

@property (assign) BOOL valid;

@property (assign, nonatomic) NSUInteger nbUnread;

- (BOOL) isGMAIL;


- (void) fetchFolders;



@end
