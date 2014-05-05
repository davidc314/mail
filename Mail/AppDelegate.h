//
//  AppDelegate.h
//  Mail
//
//  Created by Informatique on 27.01.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchField.h"
#import "AccountsManager.h"
#import "Account.h"
#import "Folder.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource,NSTableViewDelegate,NSOutlineViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *inboxTable;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenu *foldersMenu;
@property (weak) IBOutlet NSView *titleBarView;
@property (weak) IBOutlet NSView *menuItemView;
@property (weak) IBOutlet NSTextField *title;
@property (weak) IBOutlet NSOutlineView *outlineView;

@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet SearchField *search;
@property (weak) IBOutlet NSArrayController *arrayController;
@property (weak) IBOutlet NSTreeController *treeController;

@property (weak) NSArray *sortedMessages;


@property (strong) AccountsManager *accountsManager;
@property (strong) Account *selectedAccount;
@property (strong) Folder *selectedFolder;

@end
