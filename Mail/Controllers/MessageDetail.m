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
    [self openAttachment:sender];
}

- (void) rightClicked:(id)sender event:(NSEvent *)event
{
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
    
    for (Attachment *attachment in [[self.attachmentCollectionView content] objectsAtIndexes:[self.attachmentCollectionView selectionIndexes]]) {

        NSString *tempFileName = [NSTemporaryDirectory() stringByAppendingPathComponent:attachment.name];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath:tempFileName]) {
            NSLog(@"File exist");
            [fileManager removeItemAtPath:tempFileName error:NULL];
            //[[NSWorkspace sharedWorkspace]openFile:[NSString stringWithFormat:@"%@", tempFileName]];
        }
       
        const char *tempFileTemplateCString = [tempFileName fileSystemRepresentation];
        
        char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
        strcpy(tempFileNameCString, tempFileTemplateCString);
        
        int fileDescriptor = mkstemp(tempFileNameCString);
        
        if (fileDescriptor == -1) {
            NSLog(@"Error writing file");
        }
        
        
        NSFileHandle *tempFileHandle =
        [[NSFileHandle alloc]
         initWithFileDescriptor:fileDescriptor
         closeOnDealloc:NO];
        
        // Write data into created temp file
        [tempFileHandle writeData:attachment.data];
        
        // Open file with default application
        [[NSWorkspace sharedWorkspace]openFile:[NSString stringWithFormat:@"%s", tempFileNameCString]];
        
        // Free memory of tempFileNameCSString
        free(tempFileNameCString);

        
    }

}
- (IBAction)saveAttachment:(id)sender {
    
    // Single selection
    if ([[self.attachmentCollectionView content] objectsAtIndexes:[self.attachmentCollectionView selectionIndexes]].count == 1) {
        
        Attachment *a = [[self.attachmentCollectionView content] objectsAtIndexes:[self.attachmentCollectionView selectionIndexes]][0];
        
        NSSavePanel *savePanel = [NSSavePanel savePanel];
        [savePanel setNameFieldStringValue:a.name];
        
        NSInteger result = [savePanel runModal];
        
        if(result == NSOKButton) {
            [a.data writeToFile:savePanel.URL.path atomically:YES];
        }
    }
    // Multiple selection
    else {
        NSOpenPanel *choseDirectoryPanel = [NSOpenPanel openPanel];
        
        [choseDirectoryPanel setCanChooseFiles:NO];
        [choseDirectoryPanel setCanChooseDirectories:YES];
        [choseDirectoryPanel setTitle:@"Save"];
        [choseDirectoryPanel setPrompt:@"Save"];
        
        NSInteger result = [choseDirectoryPanel runModal];
        
        if(result == NSOKButton) {
            
            //Save all selected files
            for (Attachment *a in [[self.attachmentCollectionView content] objectsAtIndexes:[self.attachmentCollectionView selectionIndexes]]) {
                [a.data writeToFile:[choseDirectoryPanel.URL.path stringByAppendingPathComponent:a.name] atomically:YES];
            }
            
        }
    }
    
}
@end

