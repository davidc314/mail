//
//  Attachment.h
//  attachmentsCollectionView
//
//  Created by Informatique on 17.03.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Foundation/Foundation.h>



/** Modèle de pièce jointe */
@interface Attachment : NSObject

/** Nom de la pièce jointe */
@property (strong) NSString *name;

/** Extension du fichier */
@property (strong) NSString *ext;

/** Taille du fichier */
@property (assign) UInt64 size;

/** Icone correspondant au fichier */
@property (assign) NSImage *icon;

/** Donnée du fichier */
@property (strong) NSData *data;

/** Initialise une pièce jointe
 
 @param name Nom du fichier
 @param size Taille du fichier en Byte
 @param data Données du fichier
 
 @return Une instance initialisée de la classe Attachment
*/
- (id)initWithName:(NSString *)name size:(UInt64)size data:(NSData *)data;

@end
