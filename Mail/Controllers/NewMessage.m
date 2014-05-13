//
//  NewMessage.m
//  Mail
//
//  Created by David Coninckx on 08.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import "NewMessage.h"
#import "Message.h"
#import "Attachment.h"
#import "AccountsManager.h"

@implementation NewMessage {
    NSString *delimiterString;
}

- (id)init
{
    self = [super initWithWindowNibName:@"NewMessage"];
    [self showWindow:self];
    delimiterString = @";";
    
    NSCharacterSet *tokenizingCharSet = [NSCharacterSet characterSetWithCharactersInString:delimiterString];
    [_to setTokenizingCharacterSet:tokenizingCharSet];
    
    _attachments = [NSMutableArray array];
    self.accounts = [[AccountsManager sharedManager] accounts];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.ccFieldsView setHidden:YES];
    [self.body registerForDraggedTypes:[NSArray arrayWithObjects:
                                   NSColorPboardType, NSFilenamesPboardType, nil]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)attachment:(id)sender {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    if([openPanel runModal] == NSOKButton) {
        
        NSURL *url = [openPanel URL];
        NSFileManager *man = [NSFileManager defaultManager];
        NSDictionary *attrs = [man attributesOfItemAtPath: [url path] error: NULL];
        NSString *fileName = [[url lastPathComponent] stringByDeletingPathExtension];
        
        Attachment *attachment = [[Attachment alloc] initWithName:fileName size:[attrs fileSize] data:nil];
        
        self.attachments = [[self.attachments arrayByAddingObject:attachment] mutableCopy];
    };
    
    
}

- (IBAction)send:(id)sender {
    NSArray *to = [self.to.stringValue componentsSeparatedByString:delimiterString];
    NSArray *cc = [self.cc.stringValue componentsSeparatedByString:delimiterString];
    NSArray *bcc = [self.bcc.stringValue componentsSeparatedByString:delimiterString];
    
    to = [self convertStringToMCOAdress:to];
    cc = [self convertStringToMCOAdress:cc];
    bcc = [self convertStringToMCOAdress:bcc];
    
    Message *message = [[Message alloc] initBuildMessageWithTo:to CC:cc BCC:bcc Subject:self.subject.stringValue Body:self.body.string];
    [message sendMessage];
}

- (NSMutableArray *) convertStringToMCOAdress:(NSArray *) stringArray {
    NSMutableArray *mcoAddressArray = [NSMutableArray array];
    for(NSString *stringAdress in stringArray) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:stringAdress];
        [mcoAddressArray addObject:newAddress];
    }
    return mcoAddressArray;
}
-(IBAction)removeAttachmentItem:(id)sender
{
    id objectInClickedView = nil;
    
    for( int i = 0; i < [self.attachments count]; i++ ) {
        NSCollectionViewItem *viewItem = [self.collectionView itemAtIndex:i];
        
        if( [sender isDescendantOf:[viewItem view]] ) {
            objectInClickedView = [self.attachments objectAtIndex:i];
        }
    }
    [self.attachments removeObject:objectInClickedView];
    self.attachments = self.attachments;
}
- (void) doubleClick:(id) sender {
    NSLog(@"Attachment %@",sender);
}
-(void)dropAttachment:(id) sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
    
    for (NSString *fileName in filenames) {
        NSInteger fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:NULL] fileSize];
        Attachment *a = [[Attachment alloc] initWithName:[[NSURL URLWithString:fileName] lastPathComponent]  size:fileSize data:[NSData dataWithContentsOfFile:fileName]];
        [self.attachments addObject:a];
        NSLog(@"Attachments :%@",self.attachments);
        self.attachments = self.attachments;
    }
}
@end
