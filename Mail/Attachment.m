//
//  Attachment.m
//  attachmentsCollectionView
//
//  Created by Informatique on 17.03.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import "Attachment.h"

@implementation Attachment

- (id) initWithName:(NSString *)name ext:(NSString *)ext size:(UInt64)size {
    self = [super init];
    _name = name;
    _ext = [ext uppercaseString];
    
    if (_ext.length > 4) {
        _ext = [_ext substringToIndex:4];
    }
    _size = size;
    _icon = [[NSWorkspace sharedWorkspace] iconForFileType:ext];
    
    return self;
}
- (NSString *) description {
    return [NSString stringWithFormat:@"Name : %@ \r Extension : %@ \r Size : %llu",self.name,self.ext,self.size];
}
@end
