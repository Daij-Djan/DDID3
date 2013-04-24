//
//  id3.h
//  id3
//
//  Created by Dominik Pich on 04.03.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDID3Frame.h"
#include "libid3/globals.h"

@interface DDID3Tag : NSObject<NSFastEnumeration>

+ (DDID3Tag*)emptyTag;
+ (DDID3Tag*)tagWithContentsOfFile:(NSString*)path;

@property(readonly) const void *nativeHandle;
@property(nonatomic, copy) NSString *fileName;
- (BOOL)hasType:(ID3_TagType)type;
- (flags_t)synchronize;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@property(nonatomic, readonly) NSArray *allFrames;
-(DDID3Frame*) getFrame:(ID3_FrameID)theId;

-(void) addFrame:(DDID3Frame*)theFrame;
-(BOOL) attachFrame:(DDID3Frame*)theFrame;
-(BOOL) removeFrame:(DDID3Frame*)theFrame;

@end