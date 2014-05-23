//
//  AttachmentView.h
//  attachmentsCollectionView
//
//  Created by Coninckx David on 17.03.14.
//  Copyright (c) 2014 Coninckx David. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** Protocole de gestion des actions sur une pièce jointe */
@protocol AttachmentViewDelegate <NSObject>


/** Double cliquer */
- (void) doubleClick:(id)sender ;

/** Cliquer avec le bouton droit */
- (void) rightClicked:(id)sender event:(NSEvent *)event ;

@end

/** Vue personnalisée pour une pièce jointe */
@interface AttachmentView : NSView

/** "Delegate" de la vue */
@property IBOutlet id delegate;

/** Vue sélectionnée ? */
@property (readwrite) BOOL selected;

@end
