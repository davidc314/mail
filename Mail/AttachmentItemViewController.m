//
//  AttachmentItemViewController.m
//  attachmentsCollectionView
//
//  Created by David Coninckx on 25.03.14.
//  Copyright (c) 2014 Coninckx David. All rights reserved.
//

#import "AttachmentItemViewController.h"
#import "AttachmentView.h"

@interface AttachmentItemViewController ()

@end

@implementation AttachmentItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}
/* Double click sur une pièce jointe */
- (void) doubleClick:(id)sender {
    id delegate = [self.collectionView delegate];
    if([delegate respondsToSelector:@selector(doubleClick:)]) {
        [delegate doubleClick:[self representedObject]];
    }
}

/* Click droit sur une pièce jointe */
- (void) rightClicked:(id)sender event:(NSEvent *)event {
    id delegate = [self.collectionView delegate];
    if([delegate respondsToSelector:@selector(rightClicked:event:)]) {
        [delegate rightClicked:self event:event];
        //[self setSelected:YES];
    }
}

/* Sélectionne une joint pièce jointe */
-(void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    
    [(AttachmentView *) self.view setSelected:flag];
    [(AttachmentView *) self.view setNeedsDisplay:YES];
}

@end
