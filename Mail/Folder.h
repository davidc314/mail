//
//  Folder.h
//  Mail
//
//  Created by David Coninckx on 20.03.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

@class Account;

/** Modèle representant un dossier */
@interface Folder : NSObject

/** Nom à afficher */
@property (strong) NSString *label;

/** Chemin */
@property (strong) NSString *path;

/** Type */
@property (nonatomic,assign) MCOIMAPFolderFlag flags;

/** Messages */
@property (strong) NSMutableArray *messages;

/** Dossiers */
@property (strong) NSMutableArray *folders;

/** Nombre de message non-lus */
@property (assign) NSUInteger nbUnread;

/** Index d'ordre */
@property (assign) NSUInteger index;

/** Initialisation d'un dossier 
 @param name Chemin
 @param flags Type
 */
- (id) initWithName:(NSString *)name flags:(MCOIMAPFolderFlag) flags;

/** Récupération de l'entêtes des messages contenu dans le dossier
 @param account Compte
 */
- (void)fetchMessagesHeadersForAccount:(Account *)account;

- (void) startIDLEForAccount:(Account *)account;
@end
