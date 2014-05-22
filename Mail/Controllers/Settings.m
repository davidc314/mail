//
//  Settings.m
//  Mail
//
//  Created by David Coninckx on 12.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import "Settings.h"
#import "Account.h"
#import "AccountsManager.h"

#define FILE_NAME @"accounts.lst"

@implementation Settings

/* Initialisation de la fenêtre de paramétrage des comptes */
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        self.connectionType =[NSArray arrayWithObjects:@(MCOConnectionTypeClear),@(MCOConnectionTypeTLS),@(MCOConnectionTypeStartTLS),nil];
    }
    return self;
}

/* Fin de chargement de la fenêtre */
- (void)windowDidLoad
{
    [super windowDidLoad];
    
}

/* Ajout d'un nouveau compte */
- (IBAction)newAccount:(id)sender {
    [self willChangeValueForKey:@"accounts"];
    [[AccountsManager sharedManager] addAccount];
    [self didChangeValueForKey:@"accounts"];
}


/* Suppression d'un compte */
- (IBAction)removeAccount:(id)sender {
    NSIndexSet *indexSet = [self.arrayController selectionIndexes];
    [[AccountsManager sharedManager] removeAccountsAtIndexes:indexSet];
    [self.tableView removeRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationSlideRight];
}

/* Fermeture de l'interface de paramétrage et sauvegarde des paramètres */
- (BOOL) windowShouldClose:(id)sender {
    [self.window makeFirstResponder:self.window];
    return [[AccountsManager sharedManager] saveAccounts];
}

- (NSMutableArray *) accounts {
    NSLog(@"%@", [[AccountsManager sharedManager] accounts]);
    return [[AccountsManager sharedManager] accounts];
}

- (void) setAccounts:(NSMutableArray *)accounts {
    AccountsManager *actMan = [AccountsManager sharedManager];
    NSLog(@"Accounts : %@",accounts);
    actMan.accounts = accounts;
}

- (IBAction)columnChangeSelected:(id)sender
{
    [self.settingsView setHidden:(self.tableView.selectedRow == -1)];
}


@end
