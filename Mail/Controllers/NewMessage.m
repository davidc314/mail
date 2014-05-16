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
    self.selectedAccount = self.accounts[0];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.ccFieldsView setHidden:YES];
    
    NSArray *supportedTypes = [NSArray arrayWithObjects: NSFilenamesPboardType, nil];
    [self.attachmentCollectionView registerForDraggedTypes:supportedTypes];
    
    [self.attachmentCollectionView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    [self.attachmentCollectionView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
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
    
    to = [self convertStringToMCOAdress:to];
    
    Message *message = [[Message alloc] initBuildMessageWithTo:to subject:self.subject.stringValue body:self.body.string attachments:self.attachments];
    [message sendMessageFromAccount:self.selectedAccount];
}

- (NSMutableArray *) convertStringToMCOAdress:(NSArray *) stringArray {
    NSMutableArray *mcoAddressArray = [NSMutableArray array];
    for(NSString *stringAdress in stringArray) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:stringAdress];
        [mcoAddressArray addObject:newAddress];
    }
    return mcoAddressArray;
}

- (void) doubleClick:(id) sender {
    NSLog(@"Attachment %@",sender);
}
-(void)dropAttachment:(id)sender
{
    NSLog(@"Drop");
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
    
    for (NSString *fileName in filenames) {
        NSInteger fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:NULL] fileSize];
        Attachment *a = [[Attachment alloc] initWithName:[[NSURL fileURLWithPath:fileName] lastPathComponent]  size:fileSize data:[NSData dataWithContentsOfFile:fileName]];
        [self.attachments addObject:a];
        self.attachmentCollectionView.hasAttachment = YES;
        NSLog(@"Attachments :%@",self.attachments);
        self.attachments = self.attachments;
    }
}
-(BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id<NSDraggingInfo>)draggingInfo index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    [self dropAttachment:draggingInfo];
    return YES;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id<NSDraggingInfo>)draggingInfo proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
    return NSDragOperationCopy;
}
- (IBAction)removeAttachments:(id)sender {
    NSLog(@"Remove");
    for (Attachment *attachment in [[self.attachmentCollectionView content] objectsAtIndexes:[self.attachmentCollectionView selectionIndexes]]) {
        [self.attachments removeObject:attachment];
    }
    if (self.attachments.count == 0) {
        self.attachmentCollectionView.hasAttachment = NO;
    }
    self.attachments = self.attachments;
}
- (void) deleteAttachments {
    [self removeAttachments:nil];
}
- (void) rightClicked:(id)sender event:(NSEvent *)event
{
    NSLog(@"Right clicked");
    // Multiple selection
    if (self.attachmentCollectionView.selectionIndexes.count > 1) {
        
        if (![[self.attachmentCollectionView selectionIndexes] containsIndex:[[self.attachmentCollectionView subviews] indexOfObject:[sender view]]]) {
            [self.attachmentCollectionView setSelectionIndexes:[NSIndexSet indexSet]];
            [sender setSelected:YES];
        }
    }
    
    // Single selection
    else {
        [self.attachmentCollectionView setSelectionIndexes:[NSIndexSet indexSet]];
        [sender setSelected:YES];
    }
    [NSMenu popUpContextMenu:self.attachmentContextMenu withEvent:event forView:[sender view]];
}

@end
