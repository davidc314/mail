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

/* Initialisation d'un message avec son contenu */
-(id)initWithMessage:(Message *)message folder:(Folder *)folder account:(Account *)account {
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

/* Fin de chargement de la fenêtre */
- (void) windowDidLoad {
    [self.attachmentCollectionView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

/* Ouverture d'une pièce jointe avec un double click */
-(void)doubleClick:(id) sender
{
    [self openAttachment:sender];
}

/* Affichage du menu contextuel relatif aux pièces jointes avec le click droit */
- (void) rightClicked:(id)sender event:(NSEvent *)event
{
    /* Cas d'une séléction de plusieurs pièces jointes */
    if (self.attachmentCollectionView.selectionIndexes.count > 1) {
        
        if (![[self.attachmentCollectionView selectionIndexes] containsIndex:[[self.attachmentCollectionView subviews] indexOfObject:[sender view]]]) {
            [self.attachmentCollectionView setSelectionIndexes:[NSIndexSet indexSet]];
            [sender setSelected:YES];
        }
    }
    
    /* Cas de séléction d'une seule pièce jointe */
    else {
        [self.attachmentCollectionView setSelectionIndexes:[NSIndexSet indexSet]];
        [sender setSelected:YES];
    }
    
    /* Affichage du menu contextuel */
    [NSMenu popUpContextMenu:self.attachmentContextMenu withEvent:event forView:[sender view]];
}

/* Ouverture d'une ou plusieurs pièce(s) jointe(s) */
- (IBAction)openAttachment:(id)sender {
    
    for(Attachment *attachment in [[self.attachmentCollectionView content] objectsAtIndexes:[self.attachmentCollectionView selectionIndexes]]) {
        
        /* Nom de fichier temporaire le fichier à ouvrir */
        NSString *tempFileName = [NSTemporaryDirectory() stringByAppendingPathComponent:attachment.name];
        
        /* Gestionnaire de fichier */
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        /* Fichier existe ? */
        if([fileManager fileExistsAtPath:tempFileName]) {
            NSLog(@"File exist");
            [fileManager removeItemAtPath:tempFileName error:NULL];
        }
        
        /* Code C pour la création du fileDescriptor */
        const char *tempFileTemplateCString = [tempFileName fileSystemRepresentation];
        
        char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
        strcpy(tempFileNameCString, tempFileTemplateCString);
        
        int fileDescriptor = mkstemp(tempFileNameCString);
        
        if (fileDescriptor == -1) {
            NSLog(@"Error writing file");
        }
        
        /* Gestionnaire pour le fichier temporaire */
        NSFileHandle *tempFileHandle =
        [[NSFileHandle alloc]
         initWithFileDescriptor:fileDescriptor
         closeOnDealloc:NO];
        
        /* Ecriture des données dans le fichier */
        [tempFileHandle writeData:attachment.data];
        
        /* Ouverture du fichier */
        [[NSWorkspace sharedWorkspace]openFile:[NSString stringWithFormat:@"%s", tempFileNameCString]];
        
        /* Libère le variable C du nom de fichier */
        free(tempFileNameCString);

        
    }

}

/* Sauvegarde des pièces jointes */
- (IBAction)saveAttachment:(id)sender {
    
    /* Séléction simple */
    if ([[self.attachmentCollectionView content] objectsAtIndexes:[self.attachmentCollectionView selectionIndexes]].count == 1) {
        
        /* Pièce jointe */
        Attachment *a = [[self.attachmentCollectionView content] objectsAtIndexes:[self.attachmentCollectionView selectionIndexes]][0];
        
        /* Choix de l'emplacement de sauvegarde et du nom du fichier */
        NSSavePanel *savePanel = [NSSavePanel savePanel];
        [savePanel setNameFieldStringValue:a.name];
        
        NSInteger result = [savePanel runModal];
        
        if(result == NSOKButton) {
            /* Sauvegarde du fichier */
            [a.data writeToFile:savePanel.URL.path atomically:YES];
        }
    }
    /* Séléction multiple */
    else {
        /* Choix de l'emplacement de sauvegarde */
        NSOpenPanel *choseDirectoryPanel = [NSOpenPanel openPanel];
        
        [choseDirectoryPanel setCanChooseFiles:NO];
        [choseDirectoryPanel setCanChooseDirectories:YES];
        [choseDirectoryPanel setTitle:@"Save"];
        [choseDirectoryPanel setPrompt:@"Save"];
        
        NSInteger result = [choseDirectoryPanel runModal];
        
        if(result == NSOKButton) {
            
            /* Sauvegarde de tout les fichiers séléctionnés */
            for (Attachment *a in [[self.attachmentCollectionView content] objectsAtIndexes:[self.attachmentCollectionView selectionIndexes]]) {
                [a.data writeToFile:[choseDirectoryPanel.URL.path stringByAppendingPathComponent:a.name] atomically:YES];
            }
            
        }
    }
    
}

/* Définit l'action à effectuer au "drop" des fichiers */
- (BOOL)collectionView:(NSCollectionView *)cv writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard
{
    /* Dossier temporaire pour le stockage des fichers drop */
    NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSMutableArray *urls = [NSMutableArray array];
    
    for (Attachment *a in [self.message.attachments objectsAtIndexes:indexes]) {
         NSURL *url = [temporaryDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", a.name]];
        [urls addObject:url];
        /* Sauvegarde des fichiers temporaires */
        [a.data writeToURL:url atomically:YES];
    }
    if ([urls count] > 0)
    {
        [pasteboard clearContents];
        /* Ecriture des fichiers à l'emplacement désiré par l'utilisateur */
        return [pasteboard writeObjects:urls];
    }
    return NO;
}
@end

