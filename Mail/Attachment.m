//
//  Attachment.m
//  attachmentsCollectionView
//
//  Created by Informatique on 17.03.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import "Attachment.h"

@implementation Attachment

/*!
    Fonction pour initialiser une pièce jointe
 
    @param name
        Nom du fichier avec son extension
    @param size
        Taille en Byte du fichier
    @param data
        Données du fichier
    @return Un objet de type Attachment
 */
- (id) initWithName:(NSString *)name size:(UInt64)size data:(NSData *)data{
    self = [super init];
    
    _name = name;
    _size = size;
    _ext = [[name componentsSeparatedByString:@"."] lastObject];
    _icon = [[NSWorkspace sharedWorkspace] iconForFileType:_ext];
    _data = data;
    
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"Name : %@ \r Extension : %@ \r Size : %llu",self.name,self.ext,self.size];
}
@end
