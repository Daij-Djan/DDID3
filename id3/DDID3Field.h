//
//  DDID3Field.h
//  id3
//
//  Created by Dominik Pich on 05.03.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "libid3/globals.h"

@interface DDID3Field : NSObject

@property(readonly) const void *nativeHandle;
@property(nonatomic, readonly) ID3_FieldID identifier;
@property(nonatomic, readonly) ID3_FieldType type;
@property(nonatomic, readonly) BOOL hasChanges;

@property(nonatomic, copy) id value;


@end
