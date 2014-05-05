//
//  fileSizeTransformer.m
//  attachmentsCollectionView
//
//  Created by Informatique on 17.03.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import "FileSizeTransformer.h"

#define KB pow(1024,1)
#define MB pow(KB,2)
#define GB pow(KB,3)

@implementation FileSizeTransformer

- (id) transformedValue:(id)value {
    UInt64 intValue = [value unsignedLongLongValue];
    float roundedValue = 0;
    NSString *stringValue;

    if (intValue >= GB) {
        roundedValue = round(intValue/GB);
        stringValue = [NSString stringWithFormat:@"%i GB",(int)roundedValue];
    }
    else if (intValue >= MB){
        roundedValue = round(intValue/MB);
        stringValue = [NSString stringWithFormat:@"%i MB",(int)roundedValue];
    }
    else if (intValue >= KB){
        roundedValue = round(intValue/KB);
        stringValue = [NSString stringWithFormat:@"%i KB",(int)roundedValue];
    }
    else {
        stringValue = [NSString stringWithFormat:@"%llu B",intValue];
    }
    return stringValue;
}

@end
