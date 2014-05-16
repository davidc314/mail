//
//  AttachmentCollectionView.h
//  Mail
//
//  Created by David Coninckx on 15.05.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol AttachmentCollectionViewDelegate <NSObject>
- (void) deleteAttachments;
@end
@interface AttachmentCollectionView : NSCollectionView

@property (assign) BOOL hasAttachment;
@end
