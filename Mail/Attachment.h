//
//  Attachment.h
//  attachmentsCollectionView
//
//  Created by Informatique on 17.03.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Attachment : NSObject

@property (strong) NSString *name;
@property (strong) NSString *ext;
@property (assign) UInt64 size;
@property (assign) NSImage *icon;

- (id) initWithName:(NSString *)name ext:(NSString *)ext size:(UInt64)size;
@end
