//
//  DDID3Field.m
//  id3
//
//  Created by Dominik Pich on 05.03.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDID3Field.h"
#import "libid3/field.h"

@implementation DDID3Field {
    ID3_Field *_nativeField;
}

- (id)init {
    assert(NO && "Cant init directly yet");
}
- (id)initWithHandle:(ID3_Field*)handle {
    NSParameterAssert(handle);
    self = [super init];
    if(self) {
        _nativeField = handle;
    }
    return self;
}

- (ID3_FieldID)identifier {
    return _nativeField->GetID();
}

- (ID3_FieldType)type {
    return _nativeField->GetType();
}

- (BOOL)hasChanges {
    return _nativeField->HasChanged();
}

- (id)value {
    ID3_FieldType type = _nativeField->GetType();
    
    switch (type) {
        case ID3FTY_NONE:
            NSLog(@"Call to get the value of an Mp3Field which has no type is ignored");
            break;
        case ID3FTY_BINARY:
            return [NSData dataWithBytes:_nativeField->GetRawBinary() length:_nativeField->BinSize()];
        case ID3FTY_INTEGER:
            return [NSNumber numberWithUnsignedInt:_nativeField->Get()];
        case ID3FTY_TEXTSTRING:
            switch(_nativeField->GetEncoding()) {
                case ID3TE_UTF8:
                    if(!_nativeField->GetRawText()) return @"";
                    return [[NSString alloc] initWithBytes:_nativeField->GetRawText() length:_nativeField->Size() encoding:NSUTF8StringEncoding];
                case ID3TE_UTF16:
                    if(!_nativeField->GetRawUnicodeText()) return @"";
                    return [[NSString alloc] initWithBytes:_nativeField->GetRawUnicodeText() length:_nativeField->Size() encoding:NSUTF16StringEncoding];
                case ID3TE_UTF16BE:
                    if(!_nativeField->GetRawUnicodeText()) return @"";
                    return [[NSString alloc] initWithBytes:_nativeField->GetRawUnicodeText() length:_nativeField->Size() encoding:NSUTF16BigEndianStringEncoding];
                case ID3TE_ISO8859_1:
                    if(!_nativeField->GetRawText()) return @"";
                    return [[NSString alloc] initWithBytes:_nativeField->GetRawText() length:_nativeField->Size() encoding:NSISOLatin1StringEncoding];
                default:
                    NSLog(@"Call to get the value of an Mp3Field which has a Text Type but any encoding isnt supported ");
            }
            break;
        default:
            NSLog(@"Call to get the value of an Mp3Field which has unknown type (%d) is ignored", type);
            break;
    }
    
    return nil;
}

- (void)setValue:(id)value {
    ID3_FieldType type = _nativeField->GetType();
    
    switch (type) {
        case ID3FTY_NONE:
            NSLog(@"Call to set the value of an Mp3Field which has no type is ignored");
            return;
        case ID3FTY_BINARY:
            if(![value isKindOfClass:[NSData class]]) {
                NSLog(@"Call to set the value of an Mp3Field which has bin type to %@ is ignored", [value class]);
                return;
            }
            _nativeField->Set((uchar*)[value bytes], [value length]);
            break;
            
        case ID3FTY_INTEGER:
            if(![value isKindOfClass:[NSNumber class]]) {
                NSLog(@"Call to set the value of an Mp3Field which has int type to %@ is ignored", [value class]);
                return;
            }
            _nativeField->Set([value unsignedIntValue]);
            break;
            
        case ID3FTY_TEXTSTRING:
            if(![value isKindOfClass:[NSString class]]) {
                NSLog(@"Call to set the value of an Mp3Field which has text type to %@ is ignored", [value class]);
                return;
            }
            if([value canBeConvertedToEncoding:NSUTF16StringEncoding]) {
                _nativeField->SetEncoding(ID3TE_UTF8);
                _nativeField->Set([value UTF8String]);
            }
            else {
                NSLog(@"We only support writing UTF16 strings atm");
            }
            break;
            
        default:
            NSLog(@"Call to set the value of an Mp3Field which has unknown type (%d) is ignored", type);
            break;
    }
    
}

//---

- (NSString *)description {
    NSString *type;
    switch (self.type) {
        case ID3FTY_NONE:
            type = @"(none)";
            break;
            
        case ID3FTY_BINARY:
            type = @"(bin)";
            break;
            
        case ID3FTY_INTEGER:
            type = @"(int)";
            break;
        case ID3FTY_TEXTSTRING:
            type = @"(text)";
            break;
        default:
            type = @"(unknown)";
            break;
    }
    id v = self.value;
    if([v isKindOfClass:[NSData class]]) v = [NSString stringWithFormat:@"%ld bytes", (unsigned long)[v length]];
    return [NSString stringWithFormat:@"%d,%@ %@", self.hasChanges, type, v];
}
@end
