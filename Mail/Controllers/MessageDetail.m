//
//  MessageDetail.m
//  Mail
//
//  Created by Informatique on 05.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import "MessageDetail.h"
#import "Attachment.h"

@implementation MessageDetail

- (id) initWithMessage:(Message *)message folder:(Folder *)folder account:(Account *)account {
    self = [super initWithWindowNibName:@"MessageDetail"];
    _message = message;
    _fetching = YES;
    
    [_message fetchBodyForFolder:folder account:account completion:^(NSString *msgBody, NSMutableArray *attachments) {
        [[_body mainFrame] loadHTMLString:msgBody baseURL:nil];
        self.message.attachments = self.message.attachments;
        self.fetching = NO;
    }]; 
    
    return self;
}
- (void) windowDidLoad {
}

- (void) doubleClick:(id) sender
{
    
}

- (void) rightClicked:(id)sender event:(NSEvent *)event
{
    NSLog(@"Right clicked on attachment %@",sender);
    
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

- (IBAction)openAttachment:(id)sender {
    
    for (Attachment* attachment in [[self.attachmentCollectionView content] objectsAtIndexes:[self.attachmentCollectionView selectionIndexes]]) {
        NSString *tempFileTemplate =
        [NSTemporaryDirectory() stringByAppendingPathComponent:@"mail.XXXXXX"];
        const char *tempFileTemplateCString =
        [tempFileTemplate fileSystemRepresentation];
        char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
        strcpy(tempFileNameCString, tempFileTemplateCString);
        int fileDescriptor = mkstemp(tempFileNameCString);
        
        if (fileDescriptor == -1) {
            NSLog(@"Error writing file");
        }
        
        free(tempFileNameCString);
        
        NSFileHandle *tempFileHandle =
        [[NSFileHandle alloc]
         initWithFileDescriptor:fileDescriptor
         closeOnDealloc:NO];
        
        //[tempFileHandle writeData:attachment.data];
        
        NSLog(@"URL : %s",tempFileNameCString);
    }

}
- (IBAction)saveAttachment:(id)sender {
}
@end

