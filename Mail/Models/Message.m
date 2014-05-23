//
//  Message.m
//  Mail
//
//  Created by Coninckx David on 06.02.14.
//  Copyright (c) 2014 Coninckx David. All rights reserved.
//

#import "Message.h"
#import "Attachment.h"

@implementation Message

/* Initialisation d'un message de test */
- (id) init
{
    self = [super init];
    _from = @"test";
    _subject = @"test";
    _date = [[NSDate alloc] init];
    
    return self;
}

/* Construction d'un message pour l'envoi */
-  (id)initBuildMessageWithTo: (NSArray *)to subject:(NSString *)subject body:(NSString *)body attachments:(NSMutableArray *)attachments
{
    self = [super init];
    _to = to;
    _subject = subject;
    _htmlBody = body;
    _attachments = attachments;
    
    return self;
}

/* Initialisation un message sur la base d'un MCOIMAPMessage */
- (id)initWithMCOIMAPMessage:(MCOIMAPMessage *)msg
{
    self = [super init];
    
    MCOMessageHeader *header = [msg header];
    if (self) {
        /* Expéditeur */
        MCOAddress *fromAddress = [header from];
        
        if ([[header from] displayName]) {
            _from = [NSString stringWithFormat:@"%@ <%@>",[fromAddress displayName],[fromAddress mailbox]];
        } else {
            _from = [NSString stringWithFormat:@"<%@>",[fromAddress mailbox]];
        }
        if ([header subject]) {
            _subject = [[header subject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            _subject = @"(No object)";
        }
        _uid = [msg uid];
        _date = [header date];
        
        /* Marqueurs */
        _flags = [msg flags];
        
        self.unread = !(_flags  & MCOMessageFlagSeen);
        _replied = _flags & MCOMessageFlagAnswered;
        _forwarded = _flags & MCOMessageFlagForwarded;
        
        /* Pièces jointes */
        _hasAttachments = [[msg attachments] count] > 0;
        
        if (_hasAttachments) {
            _attachments = [[NSMutableArray alloc] init];
        }
        
    }
    
    
    return self;
}


/* Récupération du contenu d'un message */
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
        
        /* Marqueur message lus */
        [setFlagsSeen start:^(NSError *error){}];
        self.unread = NO;
        
        /* Corps du message */
        NSString * msgBody = [msg htmlBodyRendering];
        
        /* Pièces jointes */
        self.attachments = [NSMutableArray array];
        
        if ([[msg mainPart] isKindOfClass:[MCOAbstractMultipart class]]) {
            NSArray *parts = [(MCOAbstractMultipart *)[msg mainPart] parts];
            
            for (MCOAbstractPart *part in parts) {
                //NSLog(@"Part type : %@",[part mimeType]);
            }
        }
        
        /* Initialisation des pièces jointes sur la base du modèle */
        for (MCOAttachment *attachment in [msg attachments]) {
            NSData *data = [attachment data];
            Attachment *newAttachment = [[Attachment alloc] initWithName:[attachment filename] size:[data length] data:attachment.data];
            [self.attachments addObject:newAttachment];
        }
        
        
        /* Callback */
        handler(msgBody,self.attachments);
    }];
}


/* Envoi d'un nouveau message */
- (void) sendMessageFromAccount:(Account *)account completion:(void (^)(BOOL sent))handler {

    /* Objet pour la construction du message selon la rfc */
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:account.smtpSession.username]];
    [[builder header] setTo:self.to];
    [[builder header] setSubject:self.subject];
    [builder setHTMLBody:self.htmlBody];
    
    for (Attachment *attachment in self.attachments) {
        [builder addAttachment:[MCOAttachment attachmentWithData:attachment.data filename:attachment.name]];
    }
    
    /* Données selon rfc822 */
    NSData * rfc822Data = [builder data];
    
    /* Envoi */
    MCOSMTPSendOperation *sendOperation = [account.smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(!error) {
            /* Réussi */
            NSLog(@"Message send");
            handler(YES);
        }
        else {
            /* Echoué */
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
