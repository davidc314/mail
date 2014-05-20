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
    
    /* Fenêtre de detail du message */
    MessageDetail *detail;
    
    /* Fenêtre de paramètrage des comptes */
    Settings *settings;
    
    /* Fenêtre de création d'un nouveau message */
    NewMessage *newMessage;
    
    /* Elément de la barre de status */
    NSStatusItem *status;
    
    

}
- (id)init {
    self = [super init];
    
    /* Initialisation du gestionnaire de comptes */
    _accountsManager = [AccountsManager sharedManager];
    
    /* Enregistrement de l'observer pour la notification des changements sur les messages */
    [self registerAsObserver];
    
    if ([[_accountsManager accounts] count] != 0) {
        
        /* Initialisation du compte selectionné */
        _selectedAccount = [_accountsManager accounts][0];
        
        /* Initialisation du dossier selecitoné */
        _selectedFolder = _selectedAccount.folders[0];
    }
    
    /* Initisation du menu de status */
    [self initStatusMenu];
    
    //Tri des messages
    NSSortDescriptor *messageSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    _sortedMessages = [NSArray arrayWithObject:messageSortDescriptor];
    
    //Tri des dossiers
    NSSortDescriptor *folderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    self.sortedFolders = [NSArray arrayWithObject:folderSortDescriptor];
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    /* Filtre de recherche */
    [self.search bind:@"predicate" toObject:self.arrayController withKeyPath:@"filterPredicate" options:@{NSPredicateFormatBindingOption: @"from contains[cd] $value || subject contains[cd] $value"}];
    
    /* Double click sur un message */
    [self.inboxTable setDoubleAction:@selector(doubleClicked)];
    
    /* Tri des folders */
    [self.treeController rearrangeObjects];
}

/* Initialisation de la barre de status */
- (void) initStatusMenu {
    status = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    /* Recupération de l'icône */
    NSImage *iconNotif = [NSImage imageNamed:@"new_logo_notif"];
    
    /* Definition de l'élément de status avec l'image récupérée */
    [status setImage:iconNotif];
    [status setTitle:[NSString stringWithFormat:@"%lu",self.accountsManager.nbUnread]];
}

/* Choix du dossier dans la vue en arbre */
- (IBAction)choseFolder:(id)sender {
    self.selectedAccount = [[[sender itemAtRow:[sender selectedRow]] parentNode] representedObject];
    self.selectedFolder = [[sender itemAtRow:[sender selectedRow]] representedObject];
}

/* Suppression d'un message */
- (IBAction)deleteMessage:(id)sender
{
    /* Les messages à supprimer */
    NSArray *deletedMessages = [self.arrayController selectedObjects];
    
    /* Les indexes des messages à supprimer */
    NSIndexSet *indexSet = [self.arrayController selectionIndexes];
    
    /* Les identifiants unique des messages à supprimer */
    MCOIndexSet *deleteUids = [MCOIndexSet indexSet];
    
    /* Suppression avec l'animation */
    [self.inboxTable removeRowsAtIndexes:indexSet withAnimation: NSTableViewAnimationSlideRight];
    
    /* Suppresion dans le tableau de messages */
    [self.selectedFolder.messages removeObjectsInArray:deletedMessages];
    
    /* Remplissage du tableau des identifiants uniques */
    for (Message *deleteMessage in deletedMessages) {
        [deleteUids addIndex:[deleteMessage uid]];
    }
    
    /* Requête de suppression envoyée au serveur */
    MCOIMAPOperation *delete = [[self.selectedAccount imapSession] storeFlagsOperationWithFolder:self.selectedFolder.path
                                                            uids:deleteUids
                                                            kind:MCOIMAPStoreFlagsRequestKindAdd
                                                            flags:MCOMessageFlagDeleted];
    /* Démarage de la requête */
    [delete start:^(NSError *delError){
        if(!delError) {
            MCOIMAPOperation *expungeOp = [[self.selectedAccount imapSession] expungeOperation:self.selectedFolder.path];
            [expungeOp start:^(NSError *expError) {
                if(!expError) {
                    /* Suppression effectuée sans erreur */
                    NSLog(@"Delete sucessful");
                }
            }];
        }
    }];
    
    
}

/* Ouverture d'un message avec un double click */
- (void)doubleClicked
{
    if([self.inboxTable clickedRow] != -1) {
        NSInteger row = [self.inboxTable clickedRow];
        detail = [[MessageDetail alloc] initWithMessage:[self.arrayController arrangedObjects][row] folder:self.selectedFolder account:self.selectedAccount];
        [detail showWindow:self];
    }
}

/* Ouverture des paramètres de comptes */
- (IBAction)openSettings:(id)sender {
    settings = [[Settings alloc] initWithWindowNibName:@"Settings"];
    [settings showWindow:self];
}

/* Ouverture de l'interface de création d'un nouveau message */
- (IBAction)newMessage:(id)sender {
    newMessage = [[NewMessage alloc] init];
}

/* Enlève la possibilité de séléctionner les comptes dans la "NSOutlineView" */
- (BOOL) outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ![[item representedObject] isKindOfClass:[Account class]];
}

/* Définit la vue utilisée en fonction du type d'objet à représenter */
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

/* "Observer" afin d'actualiser le nombre de messages non-lus */
- (void)registerAsObserver
{
    for (Account *a in self.accountsManager.accounts) {
        /* Ajout d'un observer sur chaque compte */
        [a addObserver:self
            forKeyPath:@"nbUnread"
               options:(NSKeyValueObservingOptionNew |
                        NSKeyValueObservingOptionOld)
               context:NULL];
    }
    
}

/* Définition de l'"Observer" */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSUInteger count = 0;
    
    /* Calcul du nombre de messages non-lus */
    for (Account *account in self.accountsManager.accounts) {
        count += account.nbUnread;
    }
    
    self.accountsManager.nbUnread = count;
    [status setTitle:[NSString stringWithFormat:@"%lu",count]];
}

@end
