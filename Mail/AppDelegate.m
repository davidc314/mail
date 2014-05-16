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
    
    //Sort the folders
    NSSortDescriptor *folderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index"
                                                 ascending:YES];
    self.sortedFolders = [NSArray arrayWithObject:folderSortDescriptor];
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.search bind:@"predicate" toObject:self.arrayController withKeyPath:@"filterPredicate" options:@{NSPredicateFormatBindingOption: @"from contains[cd] $value || subject contains[cd] $value"}];
    [self.inboxTable setDoubleAction:@selector(doubleClicked)];
    
    [self.treeController rearrangeObjects];
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

- (IBAction)deleteMessage:(id)sender
{
    NSArray *deletedMessages = [self.arrayController selectedObjects];
    NSIndexSet *indexSet = [self.arrayController selectionIndexes];
    
    MCOIndexSet *deleteUids = [MCOIndexSet indexSet];
    
    [self.inboxTable removeRowsAtIndexes:indexSet withAnimation: NSTableViewAnimationSlideRight];
    [self.selectedFolder.messages removeObjectsInArray:deletedMessages];
    
    for (Message *deleteMessage in deletedMessages) {
        [deleteUids addIndex:[deleteMessage uid]];
    }
   
    MCOIMAPOperation *delete = [[self.selectedAccount imapSession] storeFlagsOperationWithFolder:self.selectedFolder.path
                                                            uids:deleteUids
                                                            kind:MCOIMAPStoreFlagsRequestKindAdd
                                                            flags:MCOMessageFlagDeleted];
    
    [delete start:^(NSError *delError){
        if(!delError) {
            MCOIMAPOperation *expungeOp = [[self.selectedAccount imapSession] expungeOperation:self.selectedFolder.path];
            [expungeOp start:^(NSError *expError) {
                if(!expError) {
                    NSLog(@"Delete sucessful");
                }
            }];
        }
    }];
    
    
}
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
