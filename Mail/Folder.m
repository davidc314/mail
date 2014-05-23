//
//  Folder.m
//  Mail
//
//  Created by David Coninckx on 20.03.14.
//  Copyright (c) 2014 Coninckx David. All rights reserved.
//

#import "Folder.h"
#import "Message.h"

#define GMAIL_DEFAULT_FOLDER @"[Gmail]"
#define TAB @"  "

@implementation Folder


-(id) initWithName:(NSString *)name flags:(MCOIMAPFolderFlag) flags {
    self = [super init];
    if (self) {
        _flags = flags;
        _path = name;
        _label = _path;
        _folders = [NSMutableArray array];
        
        
    }

    return self;
}


- (NSString *) description {
    return self.label;
}

/* Récupère les entêtes des messages pour le compte passé en paramètre */
- (void)fetchMessagesHeadersForAccount:(Account *)account
{
    MCOIMAPMessagesRequestKind requestKind = MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindFlags | MCOIMAPMessagesRequestKindStructure;
    
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)];
    
    MCOIMAPFetchMessagesOperation *fetchOperation = [account.imapSession fetchMessagesByUIDOperationWithFolder:self.path requestKind:requestKind uids:uids];
    
    [fetchOperation start:^(NSError * error, NSArray * fetchedMessages, MCOIndexSet * vanishedMessages) {
        if(error) {
            NSLog(@"Error downloading message headers for account/folder:%@/%@",account,self);
            return;
        }
        NSMutableArray *messages = [NSMutableArray array];
       
        
        for (MCOIMAPMessage *msg in fetchedMessages) {
            Message *message = [[Message alloc] initWithMCOIMAPMessage:msg];
            [messages addObject:message];
        }
        
        self.messages = messages;
        //[self registerAsObserver];
        [self updateNbUnread];
        
        
        //[self startIDLEForAccount:account];
    }];
    
}

- (BOOL) isLeaf {
    return self.folders.count==0;
}
    
- (NSImage *)image {
    NSImage *image;
    
    if ([self.label isEqualToString:@"Inbox"]) {
        image = [NSImage imageNamed:@"inbox"];
    }
    else if ([self.label isEqualToString:@"Sent"]) {
        image = [NSImage imageNamed:@"outbox"];
    }
    else if ([self.label isEqualToString:@"Trash"]) {
        image = [NSImage imageNamed:@"trash"];
    }
    else if ([self.label isEqualToString:@"Drafts"]) {
        image = [NSImage imageNamed:@"draft"];
    }
    else if ([self.label isEqualToString:@"Spam"]) {
        image = [NSImage imageNamed:@"spam"];
    }
    else if ([self.label isEqualToString:@"Starred"]) {
        image = [NSImage imageNamed:@"starred"];
    }
    else if ([self.label isEqualToString:@"Important"]) {
        image = [NSImage imageNamed:@"important"];
    }
    else {
        image = [NSImage imageNamed:@"folder"];
    }
    
    [image setTemplate:YES];
    
    return image;
}

/* Met à jour le nombre de message non-lus dans un dossier */
- (void)updateNbUnread
{
    self.nbUnread = [[self.messages valueForKeyPath:@"@sum.unread"] integerValue];
}

/* Gère les notifications IMAP (IDLE) */
- (void) startIDLEForAccount:(Account *)account {
    Message *lastMessage = [self.messages lastObject];
    MCOIMAPIdleOperation *idleOperation = [account.imapSession idleOperationWithFolder:self.path lastKnownUID:(int)[lastMessage uid]];

    [idleOperation start:^(NSError *error) {
        NSLog(@"IDLE : %@/%@",account,self.path);
        [self fetchMessagesHeadersForAccount:account];
        //[self fetchMessagesHeadersForAccount:account];
        //if (error) {
            //NSLog(@"IDLE %@",error);
        //}
    }];
}

@end
