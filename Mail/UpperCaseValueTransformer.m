//
//  UpperCaseValueTransformer.m
//  Mail
//
//  Created by David Coninckx on 12.05.14.
//  Copyright (c) 2014 Coninckx. All rights reserved.
//

#import "UpperCaseValueTransformer.h"

@implementation UpperCaseValueTransformer

-(id) transformedValue:(id)value {
    return [value uppercaseString];
}
@end
