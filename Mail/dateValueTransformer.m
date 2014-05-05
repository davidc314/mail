//
//  dateValueTransformer.m
//  Mail
//
//  Created by David Coninckx on 31.03.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import "DateValueTransformer.h"

@implementation DateValueTransformer

- (id) transformedValue:(id)value {
    NSString *stringDate;
    
    if(value) {
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"dd/MM/yyyy HH:mm"];
        stringDate = [dateFormater stringFromDate:value];
    }
    else {
        stringDate = @"-";
    }
        
    return stringDate;
}
@end
