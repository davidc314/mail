//
//  AccountsManager.m
//  Mail
//
//  Created by David Coninckx on 27.03.14.
//  Copyright (c) 2014 Coninckx David. All rights reserved.
//

#import "AccountsManager.h"

#define FILE_NAME @"accounts.plist"

@implementation AccountsManager

/* Méthode du design pattern Singleton */
+ (id)sharedManager {
    static AccountsManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

/* Fetch du contenu des comptes configuré */
- (void) fetchAll {
    for (Account *account in _accounts) {
        [account fetchFolders];
    }
}

/* Initialisation du gestionnaire */
- (id)init {
    if (self = [super init]) {
        _accounts = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForDataFile]];
        if (!_accounts)
            _accounts = [[NSMutableArray alloc] init];
        [self fetchAll];
    }
    return self;
}

/* Ajoute un compte au gestionnaire */
- (void) addAccount {
    Account *newAccount  = [[Account alloc] init];
    [self.accounts addObject:newAccount];
}

/* Suppression d'un ou plusieurs comptes */
- (void) removeAccountsAtIndexes:(NSIndexSet *)indexes {
    [self.accounts removeObjectsAtIndexes:indexes];
}

/* Sauvegarde des paramétres des comptes */
- (BOOL) saveAccounts {
    return [NSKeyedArchiver archiveRootObject:self.accounts toFile:[self pathForDataFile]];
}

/* Chemin de sauvegarde des paramètres de compte */
- (NSString *) pathForDataFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/Mail/";
    folder = [folder stringByExpandingTildeInPath];
    
    /* Test si le dossier existe */
    if ([fileManager fileExistsAtPath: folder] == NO)
    {
        [fileManager createDirectoryAtPath: folder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *fileName = FILE_NAME;
    return [folder stringByAppendingPathComponent: fileName];
}



@end
