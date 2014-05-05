//
//  AppDelegate.m
//  Mail
//
//  Created by Informatique on 27.01.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import "AppDelegate.h"
#import <MailCore/MailCore.h>
#import "MessageDetail.h"
#import "NewMessage.h"
#import "Settings.h"
#import "Message.h"
#import "Account.h"

#import "FolderRowView.h"

@implementation AppDelegate
{
    MessageDetail *detail;
    Settings *settings;
    NewMessage *newMessage;
    
    NSStatusItem *status;
    
    

}
- (id)init {
    self = [super init];
  
    _accountsManager = [AccountsManager sharedManager];
    [self registerAsObserver];
    
    if ([[_accountsManager accounts] count] != 0) {
        _selectedAccount = [_accountsManager accounts][0];
        _selectedFolder = _selectedAccount.folders[0];
    }
    
    [self initStatusMenu];
    
    
    //Sort the messages
    NSSortDescriptor *messageSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    _sortedMessages = [NSArray arrayWithObject:messageSortDescriptor];
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.search bind:@"predicate" toObject:self.arrayController withKeyPath:@"filterPredicate" options:@{NSPredicateFormatBindingOption: @"from contains[cd] $value || subject contains[cd] $value"}];
    [self.inboxTable setDoubleAction:@selector(doubleClicked)];
    
    [self.progress setHidden:YES];
    //[self choseAccount:[self.statusMenu itemAtIndex:0]];
    
    [self.treeController rearrangeObjects];
    
    [[NSImage imageNamed:@"reply"] setTemplate:YES];
    [[NSImage imageNamed:@"forward"] setTemplate:YES];
    [[NSImage imageNamed:@"attachment"] setTemplate:YES];
}


- (void) initStatusMenu {
    //init status bar
    status = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage *iconNotif = [NSImage imageNamed:@"new_logo_notif"];
    [status setImage:iconNotif];
    [status setTitle:[NSString stringWithFormat:@"%lu",self.accountsManager.nbUnread]];
}


- (IBAction)refresh:(id)sender {
    [status setTitle:[NSString stringWithFormat:@"%lu",self.accountsManager.nbUnread]];
    [self.selectedFolder fetchMessagesHeadersForAccount:self.selectedAccount];
    [self.outlineView reloadData];
}


- (IBAction)choseFolder:(id)sender {
    self.selectedAccount = [[[sender itemAtRow:[sender selectedRow]] parentNode] representedObject];
    self.selectedFolder = [[sender itemAtRow:[sender selectedRow]] representedObject];
}
/*
- (void) choseAccount:(id)sender {
    self.selectedAccount = [[self.accountsManager accounts] objectAtIndex:[sender tag]];
    
    for (NSMenuItem *item in self.statusMenu.itemArray) {
        [item setState:0];
    }
    [sender setState:1];
    
    self.selectedFolder = self.selectedAccount.folders[0];
    
    [self.title setStringValue:[NSString stringWithFormat:@"%@ <%@>",self.selectedAccount.name,self.selectedAccount.mail]];
    [self.treeController rearrangeObjects];
}*/

- (IBAction)deleteMessage:(id)sender {
    
    NSIndexSet *indexSet = [self.arrayController selectionIndexes];
    NSArray *deletedMessages = [self.arrayController selectedObjects];
    MCOIndexSet *deleteUids = [MCOIndexSet indexSet];
    
    [self.inboxTable removeRowsAtIndexes:indexSet withAnimation: NSTableViewAnimationSlideRight];
    [self.selectedFolder.messages removeObjectsInArray:deletedMessages];
    
    for (Message *deleteMessage in deletedMessages) {
        [deleteUids addIndex:[deleteMessage uid]];
    }
    
    MCOIMAPOperation *delete = [[self.selectedAccount imapSession] storeFlagsOperationWithFolder:@"INBOX"
                                                            uids:deleteUids
                                                            kind:MCOIMAPStoreFlagsRequestKindAdd
                                                            flags:MCOMessageFlagDeleted];
    
    [delete start:^(NSError *delError){
        if(!delError) {
            MCOIMAPOperation *expungeOp = [[self.selectedAccount imapSession] expungeOperation:@"INBOX"];
            [expungeOp start:^(NSError *expError) {
                if(!expError) {
                }
            }];
        }
    }];
    
    
}
/*
- (IBAction)fetchMessagesForAccount:(Account *)account folder:(Folder *)folder {
    NSLog(@"Fetch for folder : %@",folder.name);
    
    [Message fetchMessagesInFolder:folder account:account completion:^(NSMutableArray *msgs,NSUInteger nbUnread) {
        self.messages = msgs;
        [self.progress stopAnimation:self];
        [self.progress setHidden:YES];
        folder.nbUnseenMessages = nbUnread;
        account.nbUnread = 0;
        
        for (Folder *folder in account.folders) {
            account.nbUnread += folder.nbUnseenMessages;
        }
        NSLog(@"Unread : %lu",account.nbUnread);
        account.menuViewController.number = [NSString stringWithFormat:@"%lu",account.nbUnread];
        [self refreshAccountMenu];
    }];
}

- (void) fetchFolders {
    [Folder fetchFoldersInAccount:selectedAccount completion:^(NSMutableArray *folders){
        self.folders = folders;
        selectedAccount.folders = folders;
        
        if ([[selectedAccount folders] count] != 0 && !selectedFolder) {
            selectedFolder = [selectedAccount folders][0];
        }
        
        [self fetchMessagesForAccount:selectedAccount folder:selectedFolder];
    }];
}
*/
- (void)doubleClicked
{
    if([self.inboxTable clickedRow] != -1) {
        NSInteger row = [self.inboxTable clickedRow];
        detail = [[MessageDetail alloc] initWithMessage:[self.arrayController arrangedObjects][row] folder:self.selectedFolder account:self.selectedAccount];
        [detail showWindow:self];
    }
}
- (IBAction)openSettings:(id)sender {
    settings = [[Settings alloc] initWithWindowNibName:@"Settings"];
    [settings showWindow:self];
}
- (IBAction)newMessage:(id)sender {
    newMessage = [[NewMessage alloc] init];
}
- (BOOL) outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ![[item representedObject] isKindOfClass:[Account class]];
}
- (NSView *) outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item  {
    
    if ([[item representedObject] isKindOfClass:[Account class]]) {
        return [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
    }
    else {
        return [outlineView makeViewWithIdentifier:@"FolderCell" owner:self];
    }
    
}
- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    return [[FolderRowView alloc] init];
}

- (void)registerAsObserver
{
    for (Account *a in self.accountsManager.accounts) {
        [a addObserver:self
            forKeyPath:@"nbUnread"
               options:(NSKeyValueObservingOptionNew |
                        NSKeyValueObservingOptionOld)
               context:NULL];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSUInteger count = 0;
    
    for (Account *account in self.accountsManager.accounts) {
        count += account.nbUnread;
    }
    
    self.accountsManager.nbUnread = count;
    [status setTitle:[NSString stringWithFormat:@"%lu",count]];
}

@end
