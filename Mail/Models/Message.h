//
//  Message.h
//  Mail
//
//  Created by Informatique on 06.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

#import "Account.h"
#import "Folder.h"

@interface Message : NSObject

@property (assign) MCOMessageFlag flags;
@property (assign) NSInteger uid;
@property (strong) NSDate *date;
@property (strong) NSString  *from;
@property (strong) NSArray  *to;
@property (strong) NSArray  *cc;
@property (strong) NSArray  *bcc;
@property (strong) NSString  *subject;
@property (strong) NSString  *htmlBody;

@property (strong) NSMutableArray *attachments;
@property (assign) BOOL hasAttachments;

@property (assign) BOOL replied;
@property (assign) BOOL forwarded;
@property (assign, nonatomic) BOOL unread;

- (void)fetchBodyForFolder:(Folder *)folder account:(Account *)account completion:(void (^)(NSString *, NSMutableArray *))handler;

- (id)initWithMCOIMAPMessage:(MCOIMAPMessage *)msg;
//- (void)fetchBodyForFolder:(Folder *)folder account:(Account *)account completion:(void (^)(NSString * msgBody,NSMutableArray *attachments))handler;
- (id)initBuildMessageWithTo: (NSArray *)to CC:(NSArray *)cc BCC:(NSArray *)bcc Subject:(NSString *)subject Body:(NSString *)body;


- (void)sendMessage;

@end
