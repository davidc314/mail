//
//  Folder.m
//  Mail
//
//  Created by David Coninckx on 20.03.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
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
        _name = name;
        _label = _name;
        _folders = [NSMutableArray array];
        
        
    }

    return self;
}


- (NSString *) description {
    return self.label;
}

- (void)fetchMessagesHeadersForAccount:(Account *)account
{
    MCOIMAPMessagesRequestKind requestKind = MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindFlags | MCOIMAPMessagesRequestKindStructure;
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)];
    MCOIMAPFetchMessagesOperation *fetchOperation = [account.imapSession fetchMessagesByUIDOperationWithFolder:self.name requestKind:requestKind uids:uids];
    
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


- (void)updateNbUnread
{
    self.nbUnread = [[self.messages valueForKeyPath:@"@sum.unread"] integerValue];
}
/*
- (void)registerAsObserver
{
    for (Message *m in self.messages) {
        [m addObserver:self
            forKeyPath:@"unread"
               options:(NSKeyValueObservingOptionNew |
                        NSKeyValueObservingOptionOld)
               context:NULL];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog (@"Pif");
    
    [self updateNbUnread];
}*/

- (void) startIDLEForAccount:(Account *)account {
    Message *lastMessage = [self.messages lastObject];
    MCOIMAPIdleOperation *idleOperation = [account.imapSession idleOperationWithFolder:self.name lastKnownUID:(int)[lastMessage uid]];
    // NSLog(@"Start IDLE %@/%@",account,self);
    [idleOperation start:^(NSError *error) {
        NSLog(@"IDLE : %@/%@",account,self.name);
        
        [self fetchMessagesHeadersForAccount:account];
        if (error) {
            NSLog(@"IDLE %@",error);
        }
    }];
}

@end
