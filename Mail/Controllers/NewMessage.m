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
        NSCollectionViewItem *viewItem = [self.attachmentCollectionView itemAtIndex:i];
        
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
-(void)dropAttachment:(id)sender
{
    NSLog(@"Drop");
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
    
    for (NSString *fileName in filenames) {
        NSInteger fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:NULL] fileSize];
        Attachment *a = [[Attachment alloc] initWithName:[[NSURL fileURLWithPath:fileName] lastPathComponent]  size:fileSize data:[NSData dataWithContentsOfFile:fileName]];
        [self.attachments addObject:a];
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
    self.attachments = self.attachments;
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
