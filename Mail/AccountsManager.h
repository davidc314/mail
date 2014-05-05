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


@interface AccountsManager : NSObject

@property (strong) NSMutableArray *accounts;
@property (assign, nonatomic) NSUInteger nbUnread;

+ (id)sharedManager;

- (void) addAccount;
- (void) removeAccountsAtIndexes:(NSIndexSet *)indexes;
- (BOOL) saveAccounts;

- (NSUInteger) nbUnread;

@end
