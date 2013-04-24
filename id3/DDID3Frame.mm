//
//  DDID3Frame.m
//  id3
//
//  Created by Dominik Pich on 04.03.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDID3Frame.h"
#import "libid3/field.h"
#import "libid3/id3lib_frame.h"

@interface DDID3Field (nativeHandle)
- (id)initWithHandle:(ID3_Field*)handle;
@end

@implementation DDID3Frame {
    ID3_Frame *_nativeFrame;
    BOOL _ownsHandle;
    NSMutableArray *_allFields;
}

+ (DDID3Frame*)emptyFrame {
    return [[self alloc] init];
}

- (id)init {
    self = [super init];
    if(self) {
        _ownsHandle = YES;
        _nativeFrame = new ID3_Frame();
        assert(_nativeFrame);
    }
    return self;
}
- (id)initWithHandle:(ID3_Frame*)handle {
    NSParameterAssert(handle);
    self = [super init];
    if(self) {
        _nativeFrame = handle;
    }
    return self;
}
- (void)dealloc {
    if(_ownsHandle)
        delete _nativeFrame;
}

#pragma mark lazy properties

- (const void *)nativeHandle {
    return _nativeFrame;
}

- (ID3_FrameID)identifier {
    return _nativeFrame->GetID();
}

- (void)setIdentifier:(ID3_FrameID)identifier {
    _nativeFrame->SetID(identifier);
}

- (ID3_V2Spec)spec {
    return _nativeFrame->GetSpec();
}

- (void)setSpec:(ID3_V2Spec)spec {
    if(!_nativeFrame->SetSpec(spec))
        NSLog(@"Cant set frame spec");
}

#pragma mark frames

//gets a frame
- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self.allFields objectAtIndex:idx];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [self.allFields countByEnumeratingWithState:state objects:buffer count:len];
}

-(DDID3Field *)getField:(ID3_FieldID)theId {
    for (DDID3Field *field in self.allFields) {
        if(field.identifier == theId)
            return field;
    }
    return nil;
}

- (NSArray *)allFields {
    if(!_allFields) {
        _allFields = [NSMutableArray array];
        
        ID3_Frame::Iterator* iter = _nativeFrame->CreateIterator();
        ID3_Field* field = NULL;
        while(iter && (field = iter->GetNext())) {
            DDID3Field *myField = [[DDID3Field alloc] initWithHandle:field];
            [_allFields addObject:myField];
        }
    }
    return _allFields;
}

//---

//-(BOOL) addField:(DDID3Field*)theField;
//-(BOOL) removeField:(DDID3Field*)theField;

//---

- (NSString *)description {
    if(self.allFields.count==1)
        return [NSString stringWithFormat:@"%d: %@", self.identifier, self.allFields[0]];
    
    return [NSString stringWithFormat:@"%d: %@", self.identifier, self.allFields.description];
}
@end
