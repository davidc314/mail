//
//  AttachmentCollectionView.h
//  Mail
//
//  Created by David Coninckx on 15.05.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** Protocole de gestion de la vue pour les pièces jointes */
@protocol AttachmentCollectionViewDelegate <NSObject>

/** Suppression des pièces jointes */
- (void) deleteAttachments;
@end

/** Vue personnalisée pour les pièces jointes */
@interface AttachmentCollectionView : NSCollectionView

/** Contient des pièces jointes ? */
@property (assign) BOOL hasAttachment;

@end
