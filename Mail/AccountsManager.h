//
//  AccountsManager.h
//  Mail
//
//  Created by David Coninckx on 27.03.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"
#import "Folder.h"
#import "Message.h"

/** Gestionnnaire unique (Pattern Singleton) de gestion des comptes */
@interface AccountsManager : NSObject

/** Comptes */
@property (strong) NSMutableArray *accounts;

/** Nombre de message non-lu pour tout les comptes du gestionnaire */
@property (assign, nonatomic) NSUInteger nbUnread;

/** Méthode par défaut du Pattern Singleton 
 @return L'instance unique de la classe AccountManager
 */
+ (id)sharedManager;

/** Méthode pour l'ajout d'un compte au gestionnaire */
- (void) addAccount;

/** Méthode pour la suppression d'un ou plusieurs comptes au gestionnaire 
 @param indexes Index(s) du ou des comptes à supprimer
 */
- (void) removeAccountsAtIndexes:(NSIndexSet *)indexes;

/** Méthode pour sauvegarder les paramètres des comptes dans un fichier en local */
- (BOOL) saveAccounts;

- (NSUInteger) nbUnread;

@end
