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


@interface Folder : NSObject

@property (strong) NSString *label;
@property (strong) NSString *name;
@property (assign) NSUInteger indent;
@property (nonatomic,assign) MCOIMAPFolderFlag flags;

@property (strong) NSMutableArray *messages;
@property (strong) NSMutableArray *folders;

@property (assign) NSUInteger nbUnread;

- (id) initWithName:(NSString *)name flags:(MCOIMAPFolderFlag) flags;
- (void)fetchMessagesHeadersForAccount:(Account *)account;

@end
