//
//  AccountsManager.m
//  Mail
//
//  Created by David Coninckx on 27.03.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import "AccountsManager.h"

#define FILE_NAME @"accounts.plist"

@implementation AccountsManager

+ (id)sharedManager {
    static AccountsManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void) fetchAll {
    for (Account *account in _accounts) {
        //if (account.valid) {
            [account fetchFolders];
        //}
    }
}


- (id)init {
    if (self = [super init]) {
        _accounts = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForDataFile]];
        if (!_accounts)
            _accounts = [[NSMutableArray alloc] init];
        [self fetchAll];
    }
    return self;
}

- (void) addAccount {
    Account *newAccount  = [[Account alloc] init];
    [self.accounts addObject:newAccount];
}

- (void) removeAccountsAtIndexes:(NSIndexSet *)indexes {
    [self.accounts removeObjectsAtIndexes:indexes];
}

- (BOOL) saveAccounts {
    return [NSKeyedArchiver archiveRootObject:self.accounts toFile:[self pathForDataFile]];
}

- (NSString *) pathForDataFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/Mail/";
    folder = [folder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: folder] == NO)
    {
        [fileManager createDirectoryAtPath: folder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *fileName = FILE_NAME;
    return [folder stringByAppendingPathComponent: fileName];
}



@end
