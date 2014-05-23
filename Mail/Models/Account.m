//
//  Account.m
//  Mail
//
//  Created by David Coninckx on 11.02.14.
//  Copyright (c) 2014 Coninckx David. All rights reserved.
//

#import "Account.h"
#import "Folder.h"
#import "MEssage.h"

#define NAME @"NAME"
#define MAIL @"MAIL"

#define IMAP_USERNAME @"IMAP_USERNAME"
#define IMAP_PASSWORD @"IMAP_PASSWORD"
#define IMAP_PORT @"IMAP_PORT"
#define IMAP_HOSTNAME @"IMAP_HOSTNAME"
#define IMAP_CONNECTION_TYPE @"IMAP_CONNECTION_TYPE"

#define SMTP_USERNAME @"SMTP_USERNAME"
#define SMTP_PASSWORD @"SMTP_PASSWORD"
#define SMTP_PORT @"SMTP_PORT"
#define SMTP_HOSTNAME @"SMTP_HOSTNAME"
#define SMTP_CONNECTION_TYPE @"SMTP_CONNECTION_TYPE"

#define SAME_AUTH @"SAME_AUTH"
#define VALID NO


@implementation Account

- (id) init {
    _name = @"New Account";
    _mail = @"-";
    _valid = NO;
    
    return self;
}
/* Connection au serveur IMAP */
- (void) connectToIMAP {
    self.imapSession = [[MCOIMAPSession alloc] init];
    
    [self.imapSession setHostname:self.imapHostname];
    [self.imapSession setPort:self.imapPort];
    [self.imapSession setUsername:self.imapUsername];
    [self.imapSession setPassword:self.imapPassword];
    [self.imapSession setConnectionType:self.imapConnectionType];
}

/* Connection au serveur SMTP */
-(void) connectToSMTP {
    self.smtpSession = [[MCOSMTPSession alloc] init];
    
    [self.smtpSession setHostname:self.smtpHostname];
    [self.smtpSession setPort:self.smtpPort];
    [self.smtpSession setUsername:self.imapUsername];
    [self.smtpSession setPassword:self.imapPassword];
    [self.smtpSession setConnectionType:self.smtpConnectionType];
    [self.smtpSession setAuthType:MCOAuthTypeSASLPlain | MCOAuthTypeSASLLogin];
}

/* Initialisation d'un compte à partir de l'archive stockée */
- (id) initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    /* Récupération des paramétre en fonction de leur clé */
    self.name = [decoder decodeObjectForKey:NAME];
    self.mail = [decoder decodeObjectForKey:MAIL];
    
    self.imapUsername = [decoder decodeObjectForKey:IMAP_USERNAME];
    self.imapPassword = [decoder decodeObjectForKey:IMAP_PASSWORD];
    self.imapHostname = [decoder decodeObjectForKey:IMAP_HOSTNAME];
    self.imapPort = (unsigned)[decoder decodeIntegerForKey:IMAP_PORT];
    self.imapConnectionType =  (MCOConnectionType)[decoder decodeIntegerForKey:IMAP_CONNECTION_TYPE];
    
    self.smtpUsername = [decoder decodeObjectForKey:SMTP_USERNAME];
    self.smtpPassword = [decoder decodeObjectForKey:SMTP_PASSWORD];
    self.smtpHostname = [decoder decodeObjectForKey:SMTP_HOSTNAME];
    self.smtpPort  = (unsigned)[decoder decodeIntegerForKey:SMTP_PORT];
    self.smtpConnectionType = (MCOConnectionType)[decoder decodeIntegerForKey:SMTP_CONNECTION_TYPE];
    
    self.sameAuth = [decoder decodeBoolForKey:SAME_AUTH];
    
    self.provider = [[MCOMailProvidersManager sharedManager] providerForEmail:self.mail];
    
    /* Connexion aux serveurs */
    [self connectToIMAP];
    [self connectToSMTP];
    
    [self checkAccountOperations];
    
    return self;
}
/* Ajoute un "observer" sur chaque dossier pour detecter les changements */
- (void)registerAsObserver
{
    for (Folder *f in self.folders) {
        [f addObserver:self
                  forKeyPath:@"messages"
                     options:(NSKeyValueObservingOptionNew |
                              NSKeyValueObservingOptionOld)
                     context:NULL];
    }
    
}

/* Observe les changements sur les dossiers et actualise le nombre de messages non-lus */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSUInteger count = 0;
    
    for (Folder *folder in self.folders) {
        count += folder.nbUnread;
    }
    
    self.nbUnread = count;
}

/* Vérifie la configuration du compte en testant la connexion au serveur IMAP et au serveur SMTTP */
- (void) checkAccountOperations  {
    MCOIMAPOperation *imapCheckOperation = [self.imapSession checkAccountOperation];
    MCOSMTPOperation *smtpCheckOperation = [self.smtpSession checkAccountOperationWithFrom:[MCOAddress addressWithMailbox:self.mail]];
    
   [imapCheckOperation start:^(NSError *error) {
       if (!error) {
           [smtpCheckOperation start:^(NSError *error) {
               if (!error) {
                   self.valid = YES;
               }
           }];
       }
   }];
}

/* Encode les propriétés pour les stocker dans le fichier account.plist */
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:NAME];
    [encoder encodeObject:self.mail forKey:MAIL];
    
    [encoder encodeObject:self.imapUsername forKey:IMAP_USERNAME];
    [encoder encodeObject:self.imapPassword forKey:IMAP_PASSWORD];
    [encoder encodeObject:self.imapHostname forKey:IMAP_HOSTNAME];
    [encoder encodeInteger:self.imapPort forKey:IMAP_PORT];
    [encoder encodeInteger:self.imapConnectionType forKey:IMAP_CONNECTION_TYPE];
    
    [encoder encodeObject:self.smtpUsername forKey:SMTP_USERNAME];
    [encoder encodeObject:self.smtpPassword forKey:SMTP_PASSWORD];
    [encoder encodeObject:self.smtpHostname forKey:SMTP_HOSTNAME];
    [encoder encodeInteger:self.smtpPort forKey:SMTP_PORT];
    [encoder encodeInteger:self.smtpConnectionType forKey:SMTP_CONNECTION_TYPE];
    
    [encoder encodeBool:self.sameAuth forKey:SAME_AUTH];
    
    [self connectToIMAP];
    [self connectToSMTP];
    
}
- (NSString *) description {
    return [NSString stringWithFormat:@"%@",self.name];
}


- (BOOL) isGMAIL {
    return [self.imapHostname  isEqual: @"imap.gmail.com"] && [self.smtpHostname  isEqual: @"smtp.gmail.com"];
}

/* Obtient la liste des dossiers du compte et ajoute les sous-dossier au dossier */
- (void) fetchFolders {
    NSMutableArray *folders = [NSMutableArray array];
    
    MCOIMAPFetchFoldersOperation *fetchOperation = [self.imapSession fetchAllFoldersOperation];
    
    [fetchOperation start:^(NSError *error, NSArray *fetchedFolders) {
        
        if (error) {
            NSLog(@"Error fetching folders %@",error);
        }
        
        for (MCOIMAPFolder *fetchedFolder in fetchedFolders) {
            NSMutableArray *pathComponents = [[fetchedFolder.path componentsSeparatedByString:[NSString stringWithFormat:@"%c" , fetchedFolder.delimiter]] mutableCopy];
            [pathComponents removeObject:@"[Gmail]"];
            
            
            Folder *folder = [[Folder alloc]initWithName:fetchedFolder.path flags:fetchedFolder.flags];

            if (pathComponents.count == 1) {
                [folders addObject:folder];
                folder.label = [pathComponents lastObject];
                [folder fetchMessagesHeadersForAccount:self];
            }
            
            else if (pathComponents.count > 0) {
                
                NSMutableArray *lastFolders = folders;
                
                for (NSString* path in pathComponents) {
                    if ([self containsFolder:path array:lastFolders]) {
                        lastFolders = [self containsFolder:path array:lastFolders].folders;
                    }
                    else {
                        folder.label = path;
                        [folder fetchMessagesHeadersForAccount:self];
                        [lastFolders addObject:folder];
                    }
                }
            }
            
 
        }
        
        self.folders = folders;
        [self setFoldersLabelsAndIndexes];
        self.folders = self.folders;
        [self registerAsObserver];
        
    }];
}

/* Test si le dossier et contenu dans le tableau passé en paramétre */
- (Folder *) containsFolder:(NSString *)searchedFolder array:(NSArray *)folders {
    for (Folder *folder in folders) {
        if ([folder.label isEqualToString:searchedFolder]) {
            return folder;
        }
    }
    return nil;
}

/* Définit pour chaque dossier les propriétés label et index */
- (void)setFoldersLabelsAndIndexes
{
    NSArray *folderOrder = @[@"Inbox",@"Sent",@"Drafts",@"Important",@"Starred",@"Trash",@"Spam",@"All messages"];

    for (Folder *folder in self.folders) {
        
        NSUInteger index = 10;
        
        if ([folder.path isEqualToString:@"INBOX"]) {index = 0;} // Inbox
        else if ([folder.path isEqualToString:self.provider.sentMailFolderPath] || (folder.flags & MCOIMAPFolderFlagSentMail)) {index = 1;} /* Sent */
        else if ([folder.path isEqualToString:self.provider.draftsFolderPath] || (folder.flags & MCOIMAPFolderFlagDrafts)) {index = 2;} /* Drafts */
        else if ([folder.path isEqualToString:self.provider.importantFolderPath] || (folder.flags & MCOIMAPFolderFlagImportant)) {index = 3;} /* Important */
        else if ([folder.path isEqualToString:self.provider.starredFolderPath] || (folder.flags & MCOIMAPFolderFlagStarred)) {index = 4;} /* Starred */
        else if ([folder.path isEqualToString:self.provider.trashFolderPath] || (folder.flags & MCOIMAPFolderFlagTrash)) {index = 5;} /* Trash */
        else if ([folder.path isEqualToString:self.provider.spamFolderPath] || (folder.flags & MCOIMAPFolderFlagSpam)) {index = 6;} /* Spam */
        else if ([folder.path isEqualToString:self.provider.allMailFolderPath] || (folder.flags & MCOIMAPFolderFlagAllMail)) {index = 7;} /* All Mail */
        
        if (index <= folderOrder.count) {
            folder.label = folderOrder[index];
        }
        folder.index = [folderOrder indexOfObject:folder.label];;
    }
}

- (BOOL) isLeaf {
    return NO;
}
    
- (NSString *)label {
    return self.name;
}
- (NSImage *)image {
    return nil;
}

@end
