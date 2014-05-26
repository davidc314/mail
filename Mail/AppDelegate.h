//
//  AppDelegate.h
//  Mail
//
//  Created by Coninckx David on 27.01.14.
//  Copyright (c) 2014 Coninckx David. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchField.h"
#import "AccountsManager.h"
#import "Account.h"
#import "Folder.h"

/** Classe principale dédié à la gestion de l'application */
@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource,NSTableViewDelegate,NSOutlineViewDelegate>

/** La fenêtre principale de l'interface */
@property (assign) IBOutlet NSWindow *window;

/** La vue contenant la liste des messages */
@property (weak) IBOutlet NSTableView *inboxTable;

/** Vue en arbre des comptes et des dossier configurés */
@property (weak) IBOutlet NSOutlineView *outlineView;

/** Barre de recherche pour filtrer les messages dans le dossier sélectioné  */
@property (weak) IBOutlet SearchField *search;

/** Le contrôleur du tableau de messages */
@property (weak) IBOutlet NSArrayController *arrayController;

/** Le contrôleur d'arborescence des comptes et des dossiers */
@property (weak) IBOutlet NSTreeController *treeController;

/** Les trieurs pour les messages */
@property (strong) NSArray *sortedMessages;

/** Les trieurs pour les dossiers */
@property (strong) NSArray *sortedFolders;

/** Le gestionnaire de comptes */
@property (strong) AccountsManager *accountsManager;

/** Le compte sélectionné */
@property (strong) Account *selectedAccount;

/** Le dossier sélectionné */
@property (strong) Folder *selectedFolder;

@end
