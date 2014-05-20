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

@implementation NewMessage

/* Initialisation de la fenêtre pour la création d'un nouveau message */
- (id)init
{
    self = [super initWithWindowNibName:@"NewMessage"];
    [self showWindow:self];
    
    _attachments = [NSMutableArray array];
    self.accounts = [[AccountsManager sharedManager] accounts];
    self.selectedAccount = self.accounts[0];
    return self;
}

/* Chargement de la fenêtre terminé */
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    
    /* Définit le type d'objet autorisé à être "drag" */
    NSArray *supportedTypes = [NSArray arrayWithObjects: NSFilenamesPboardType, nil];
    [self.attachmentsCollectionView registerForDraggedTypes:supportedTypes];
    
    /* Masque pour le "drag & drop" */
    [self.attachmentsCollectionView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

/* Envoie d'un message */
- (IBAction)send:(id)sender {
    
    /* Destinataires du message */
    NSArray *to = self.to.objectValue;
    
    /* Convertis les adresses en MCOAdress */
    to = [self convertStringToMCOAdress:to];
    Message *message = [[Message alloc] initBuildMessageWithTo:to subject:self.subject.stringValue body:self.body.string attachments:self.attachments];
    
    /* Test si le sujet est vide */
    if ([self.subject.stringValue isEqualToString:@""]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Send message without subject ?" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@""];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            if(returnCode == NSModalResponseOK) {
                [self sendMessage:message];
            }
        }];
    }
    else {
        [self sendMessage:message];
    }
    
   
}

/* Envoie du message et notification */
- (void) sendMessage:(Message *)message
{
    [message sendMessageFromAccount:self.selectedAccount];
    [self sendNotification:@"Message sent"];
    
    /* Fermeture de la fenêtre */
    [self.window close];
}

/* Envoie de la notification */
- (void) sendNotification:(NSString *)message
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:message];
    [notification setSubtitle:self.subject.stringValue];
    [notification setSoundName:NSUserNotificationDefaultSoundName];
    
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center setDelegate:self];
    [center deliverNotification:notification];
}

/* Convertis les adresses en MCOAdress */
- (NSMutableArray *) convertStringToMCOAdress:(NSArray *) stringArray {
    NSMutableArray *mcoAddressArray = [NSMutableArray array];
    for(NSString *stringAdress in stringArray) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:stringAdress];
        [mcoAddressArray addObject:newAddress];
    }
    return mcoAddressArray;
}

/* Double click sur une pièce jointe */
- (void) doubleClick:(id) sender {
    for(Attachment *attachment in [[self.attachmentsCollectionView content] objectsAtIndexes:[self.attachmentsCollectionView selectionIndexes]]) {
        
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

/* "Drop" des pièces jointes */
-(void)dropAttachment:(id)sender
{
    NSLog(@"Drop");
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
    
    for (NSString *fileName in filenames) {
        NSInteger fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:NULL] fileSize];
        Attachment *a = [[Attachment alloc] initWithName:[[NSURL fileURLWithPath:fileName] lastPathComponent]  size:fileSize data:[NSData dataWithContentsOfFile:fileName]];
        [self.attachments addObject:a];
        self.attachmentsCollectionView.hasAttachment = YES;
        NSLog(@"Attachments :%@",self.attachments);
        self.attachments = self.attachments;
    }
}

/* La "CollectionView" accepte les "drop" */
-(BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id<NSDraggingInfo>)draggingInfo index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    [self dropAttachment:draggingInfo];
    return YES;
}

/* Modifie le masque en fonction du survol de la zone de "drop" */
- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id<NSDraggingInfo>)draggingInfo proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
    return NSDragOperationCopy;
}

/* Supprime une ou plusieurs pièce(s) jointe(s) */
- (IBAction)removeAttachments:(id)sender {
    NSLog(@"Remove");
    for (Attachment *attachment in [[self.attachmentsCollectionView content] objectsAtIndexes:[self.attachmentsCollectionView selectionIndexes]]) {
        [self.attachments removeObject:attachment];
    }
    if (self.attachments.count == 0) {
        self.attachmentsCollectionView.hasAttachment = NO;
    }
    self.attachments = self.attachments;
}
/* Apelle la fonction de supression des pièces jointes */
- (void) deleteAttachments {
    [self removeAttachments:nil];
}

/* Fait apparaître le menu contextuel avec le clique droit */
- (void) rightClicked:(id)sender event:(NSEvent *)event
{
    NSLog(@"Right clicked");
    // Multiple selection
    if (self.attachmentsCollectionView.selectionIndexes.count > 1) {
        
        if (![[self.attachmentsCollectionView selectionIndexes] containsIndex:[[self.attachmentsCollectionView subviews] indexOfObject:[sender view]]]) {
            [self.attachmentsCollectionView setSelectionIndexes:[NSIndexSet indexSet]];
            
            /* Séléctionne manuellement la pièce jointe */
            [sender setSelected:YES];
        }
    }
    
    // Single selection
    else {
        [self.attachmentsCollectionView setSelectionIndexes:[NSIndexSet indexSet]];
        [sender setSelected:YES];
    }
    [NSMenu popUpContextMenu:self.attachmentContextMenu withEvent:event forView:[sender view]];
}

/* Force les notifications à apparaître à l'écran */
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

@end
