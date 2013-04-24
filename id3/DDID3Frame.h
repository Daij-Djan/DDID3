//
//  DDID3Frame.h
//  id3
//
//  Created by Dominik Pich on 04.03.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDID3Field.h"
#include "libid3/globals.h"

@interface DDID3Frame : NSObject<NSFastEnumeration>

+ (DDID3Frame*)emptyFrame;

@property(readonly) const void *nativeHandle;
@property(nonatomic, assign) ID3_FrameID identifier;
@property(nonatomic, assign) ID3_V2Spec spec;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@property(nonatomic, readonly) NSArray *allFields;
-(DDID3Field*) getField:(ID3_FieldID)theId;

@end
