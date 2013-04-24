//
//  id3.m
//  id3
//
//  Created by Dominik Pich on 04.03.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import  "DDID3Tag.h"
#import "libid3/tag.h"

@interface DDID3Frame (nativeHandle)
- (id)initWithHandle:(ID3_Frame*)handle;
@end

@implementation DDID3Tag {
    NSMutableArray *_allFrames;
    ID3_Tag *_nativeTag;
    BOOL _ownsHandle;
}

+ (DDID3Tag*)emptyTag {
    return [[[self class] alloc] init];
}
+ (DDID3Tag*)tagWithContentsOfFile:(NSString*)path {
    DDID3Tag *tag = [[[self class] alloc] init];
    tag.fileName = path;
    return tag;
}
- (id)init {
    self = [super init];
    if(self) {
        _ownsHandle = YES;
        _nativeTag = new ID3_Tag();
        assert(_nativeTag);
    }
    return self;
}

- (void)dealloc {
    if(_ownsHandle)
        delete _nativeTag;
}

#pragma mark methods and properties

- (const void *)nativeHandle {
    return _nativeTag;
}

- (void)setFileName:(NSString *)fileName {
    _fileName = fileName.copy;
    _allFrames = nil;
    if(_fileName && [[NSFileManager defaultManager] fileExistsAtPath:_fileName])
        _nativeTag->Link(_fileName.fileSystemRepresentation);
    else
        _nativeTag->Link(NULL);
}

- (BOOL)hasType:(ID3_TagType)type {
    return _nativeTag->HasTagType(type);
}

- (flags_t)synchronize {
    _allFrames = nil;
    return _nativeTag->Update();
}

#pragma mark frames

//gets a frame
- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self.allFrames objectAtIndex:idx];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [self.allFrames countByEnumeratingWithState:state objects:buffer count:len];
}

-(DDID3Frame*) getFrame:(ID3_FrameID)theId {
    for (DDID3Frame *frame in self.allFrames) {
        if(frame.identifier == theId)
            return frame;
    }
    return nil;
}

- (NSArray *)allFrames {
    if(!_allFrames) {
        _allFrames = [NSMutableArray array];
    
        ID3_Tag::Iterator* iter = _nativeTag->CreateIterator();
        ID3_Frame* frame = NULL;
        while(iter && (frame = iter->GetNext())) {
            DDID3Frame *myFrame = [[DDID3Frame alloc] initWithHandle:frame];
            [_allFrames addObject:myFrame];
        }
    }
    return _allFrames;
}

//---

-(void) addFrame:(DDID3Frame*)theFrame {
    _nativeTag->AddFrame((ID3_Frame*)theFrame.nativeHandle);
}

-(BOOL) attachFrame:(DDID3Frame*)theFrame {
    return _nativeTag->AttachFrame((ID3_Frame*)theFrame.nativeHandle);
}

-(BOOL) removeFrame:(DDID3Frame*)theFrame {
    ID3_Frame *rf = _nativeTag->RemoveFrame((ID3_Frame*)theFrame.nativeHandle);
    return rf==theFrame.nativeHandle;
}

//---

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"tag for %@ {\n", self.fileName];
    for (DDID3Frame *frame in self) {
        [string appendFormat:@"\t{%@},\n", [frame description]];
    }
    [string appendString:@"}"];
    return string;
}

@end
