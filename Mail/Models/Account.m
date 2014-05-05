//
//  Account.m
//  Mail
//
//  Created by David Coninckx on 11.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
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

- (void) connectToIMAP {
    self.imapSession = [[MCOIMAPSession alloc] init];
    
    [self.imapSession setHostname:self.imapHostname];
    [self.imapSession setPort:self.imapPort];
    [self.imapSession setUsername:self.imapUsername];
    [self.imapSession setPassword:self.imapPassword];
    [self.imapSession setConnectionType:self.imapConnectionType];
}

-(void) connectToSMTP {
    self.smtpSession = [[MCOSMTPSession alloc] init];
    
    [self.smtpSession setHostname:self.smtpHostname];
    [self.smtpSession setPort:self.smtpPort];
    [self.smtpSession setUsername:self.imapUsername];
    [self.smtpSession setPassword:self.imapPassword];
    [self.smtpSession setConnectionType:self.smtpConnectionType];
    [self.smtpSession setAuthType:MCOAuthTypeSASLPlain | MCOAuthTypeSASLLogin];
}

- (id) initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
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
    
    [self connectToIMAP];
    [self connectToSMTP];
    
    [self checkAccountOperations];
    
    return self;
}
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSUInteger count = 0;
    
    for (Folder *folder in self.folders) {
        count += folder.nbUnread;
    }
    
    self.nbUnread = count;
}

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
        if (![self isGMAIL]) {
            self.folders = [self sortFolders:folders provider:[[MCOMailProvidersManager sharedManager] providerForEmail:self.mail]];
        }
        else {
            self.folders = [self sortGMAILFolders:folders];
        }
        [self registerAsObserver];
        
    }];
}


- (Folder *) containsFolder:(NSString *)searchedFolder array:(NSArray *)folders {
    for (Folder *folder in folders) {
        if ([folder.label isEqualToString:searchedFolder]) {
            return folder;
        }
    }
    return nil;
}


- (id) sortFolders:(NSMutableArray *)folders provider:(MCOMailProvider *)provider {
    NSMutableArray *sortedFolders = [NSMutableArray array];
    NSDictionary * folderPaths = [NSDictionary dictionaryWithObjectsAndKeys:
                                  provider.sentMailFolderPath,@"Sent",
                                  provider.draftsFolderPath,@"Drafts",
                                  provider.importantFolderPath,@"Important",
                                  provider.starredFolderPath,@"Starred",
                                  provider.trashFolderPath,@"Trash",
                                  provider.spamFolderPath,@"Spam",
                                  provider.allMailFolderPath,@"All messages",
                                  nil];
    for (Folder *folder in folders) {
        if ([folder.name isEqualToString:@"INBOX"]) {
            [sortedFolders addObject:folder];
            folder.label = @"Inbox";
            [folders removeObject:folder];
            break;
        }
    }
    for (id path in folderPaths) {
        for (Folder *folder in folders) {
            if ([folder.name isEqualToString:folderPaths[path]]) {
                [sortedFolders addObject:folder];
                folder.label = path;
                [folders removeObject:folder];
                break;
            }
            
        }
    }
    
    [sortedFolders addObjectsFromArray:folders];
    
    return sortedFolders;
}
- (id) sortGMAILFolders:(NSMutableArray *)folders {
    NSMutableArray *sortedFolders = [NSMutableArray array];
    
    for (Folder *folder in folders) {
        if ([folder.name isEqualToString:@"INBOX"]) {
            [sortedFolders addObject:folder];
            folder.label = @"Inbox";
            [folders removeObject:folder];
            break;
        }
    }
    
    for (int i = 0; i<=12; i++) {
        for (Folder *folder in folders) {
            if (folder.flags & (1 << i)) {
                [sortedFolders addObject:folder];
                
                switch (1 << i) {
                    case (1 << 5):
                        folder.label = @"Sent";
                        break;
                    case (1 << 6):
                        folder.label = @"Starred";
                        break;
                    case (1 << 7):
                        folder.label = @"All";
                        break;
                    case (1 << 8):
                        folder.label = @"Trash";
                        break;
                    case (1 << 9):
                        folder.label = @"Drafts";
                        break;
                    case (1 << 10):
                        folder.label = @"Spam";
                        break;
                    case (1 << 11):
                        folder.label = @"Important";
                        break;
                    case (1 << 12):
                        folder.label = @"Archive";
                        break;
                    default:
                        folder.label = folder.name;
                        break;
                }
                
                [folders removeObject:folder];
                break;
            }
            
        }
    }
    [sortedFolders addObjectsFromArray:folders];
    
    return sortedFolders;
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
