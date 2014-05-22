//
//  Message.m
//  Mail
//
//  Created by Informatique on 06.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import "Message.h"
#import "Attachment.h"

@implementation Message

- (id) init
{
    self = [super init];
    _from = @"test";
    _subject = @"test";
    _date = [[NSDate alloc] init];
    
    return self;
}


-  (id)initBuildMessageWithTo: (NSArray *)to subject:(NSString *)subject body:(NSString *)body attachments:(NSMutableArray *)attachments
{
    self = [super init];
    _to = to;
    _subject = subject;
    _htmlBody = body;
    _attachments = attachments;
    
    return self;
}

- (id)initWithMCOIMAPMessage:(MCOIMAPMessage *)msg
{
    self = [super init];
    
    MCOMessageHeader *header = [msg header];
    if (self) {
        MCOAddress *fromAddress = [header from];
        
        if ([[header from] displayName]) {
            _from = [NSString stringWithFormat:@"%@ <%@>",[fromAddress displayName],[fromAddress mailbox]];
        } else {
            _from = [NSString stringWithFormat:@"<%@>",[fromAddress mailbox]];
        }
        if ([header subject]) {
            //_subject = [[header subject] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            _subject = [[header subject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            _subject = @"(No object)";
        }
        _uid = [msg uid];
        _date = [header date];
        
        //Message flags
        _flags = [msg flags];
        
        self.unread = !(_flags  & MCOMessageFlagSeen);
        _replied = _flags & MCOMessageFlagAnswered;
        _forwarded = _flags & MCOMessageFlagForwarded;
        
        //Attachments
        _hasAttachments = [[msg attachments] count] > 0;
        
        if (_hasAttachments) {
            _attachments = [[NSMutableArray alloc] init];
        }
        
    }
    
    
    return self;
}



- (void)fetchBodyForFolder:(Folder *)folder account:(Account *)account completion:(void (^)(NSString *, NSMutableArray *))handler
{
    MCOIMAPFetchContentOperation *fetchContentOperation = [account.imapSession fetchMessageByUIDOperationWithFolder:folder.path uid:(int)self.uid];
    
    
    NSLog(@"Fetch message (%lu) body for acccount : %@ folder : %@",self.uid,account,folder.path);
    
    [fetchContentOperation start:^(NSError *error,NSData *data){
        
        NSLog(@"Body fetch finished");
        if (error) {
            NSLog(@"Fetch body %@",error);
        }
        
        MCOMessageParser * msg = [MCOMessageParser messageParserWithData:data];
        MCOIMAPOperation *setFlagsSeen = [account.imapSession storeFlagsOperationWithFolder:folder.path uids:[MCOIndexSet indexSetWithIndex:self.uid] kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagSeen];
        
        //Flag seen
        [setFlagsSeen start:^(NSError *error){}];
        self.unread = NO;
        
        //Get message body
        NSString * msgBody = [msg htmlBodyRendering];
        
        //Get message attachments
        self.attachments = [NSMutableArray array];
        
        if ([[msg mainPart] isKindOfClass:[MCOAbstractMultipart class]]) {
            NSArray *parts = [(MCOAbstractMultipart *)[msg mainPart] parts];
            
            for (MCOAbstractPart *part in parts) {
                //NSLog(@"Part type : %@",[part mimeType]);
            }
        }
        
        for (MCOAttachment *attachment in [msg attachments]) {
            NSData *data = [attachment data];
            Attachment *newAttachment = [[Attachment alloc] initWithName:[attachment filename] size:[data length] data:attachment.data];
            [self.attachments addObject:newAttachment];
        }
        
        
        //Callback
        handler(msgBody,self.attachments);
    }];
}


//Send new message
- (void) sendMessageFromAccount:(Account *)account completion:(void (^)(BOOL sent))handler {

    
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:account.smtpSession.username]];
    [[builder header] setTo:self.to];
    [[builder header] setSubject:self.subject];
    [builder setHTMLBody:self.htmlBody];
    
    for (Attachment *attachment in self.attachments) {
        [builder addAttachment:[MCOAttachment attachmentWithData:attachment.data filename:attachment.name]];
    }
    
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation = [account.smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(!error) {
            NSLog(@"Message send");
            handler(YES);
        }
        else {
            NSLog(@"Message not send");
            handler(NO);
        }

        
    }];
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@/%@",self.from,self.subject];
}

@end
