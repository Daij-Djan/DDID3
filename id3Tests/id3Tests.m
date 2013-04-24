//
//  id3Tests.m
//  id3Tests
//
//  Created by Dominik Pich on 09.03.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "id3Tests.h"
#import <DDID3/DDID3.h>

@implementation id3Tests {
    NSString *_outputFilename;
    NSArray *_mp3s;
}

- (NSArray*)mp3s {
    if(!_mp3s) {
        NSString *dir = [NSBundle bundleForClass:self.class].resourcePath;
        NSMutableArray *array = [NSMutableArray array];
        
        for(NSString *child in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil]) {
            if([child.pathExtension isEqualToString:@"mp3"])
                [array addObject:[dir stringByAppendingPathComponent:child]];
        }
        _mp3s = array;
    }
    return _mp3s;
}

- (NSString *)outputFilename {
    if(!_outputFilename) {
        _outputFilename = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    }
    return _outputFilename;
}

- (void)testEmptyID3 {
    NSString *outputFilename = self.outputFilename;
    
    //copy to output
    [[NSFileManager defaultManager] copyItemAtPath:self.mp3s[0] toPath:outputFilename error:nil];
    
    //begin an empty tag
    DDID3Tag *tag2 = [DDID3Tag tagWithContentsOfFile: outputFilename];
    STAssertNotNil(tag2, @"Failed to read tag from %@", outputFilename);

    //rm all frames
    NSArray *allFrames = tag2.allFrames;
    int i = 0;
    while(i < allFrames.count){
        [tag2 removeFrame: allFrames[i]];
        i++;
    }
    
    //write it
    [tag2 synchronize];
    
    //read in the tag
    tag2 = [DDID3Tag tagWithContentsOfFile: outputFilename];
    NSLog(@"%@", tag2);
    STAssertTrue(![tag2 hasType:ID3TT_ID3V2], @"the test mp3 shouldnt have a id3 v2 tag");
    STAssertTrue(tag2.allFrames.count==0, @"the tag shouldn't have any frames");
}

- (void)testCloneID3 {
    NSString *outputFilename = self.outputFilename;
    
    //copy to output
    [[NSFileManager defaultManager] copyItemAtPath:self.mp3s[0] toPath:outputFilename error:nil];

    DDID3Tag *tag = [DDID3Tag tagWithContentsOfFile:self.mp3s[0]];
    STAssertNotNil(tag, @"Failed to init tag with data read from %@", self.mp3s[0]);

    //make sure the original has an id3 tag
    STAssertTrue([tag hasType:ID3TT_ID3V2], @"the test mp3 should have a id3 v2 tag");
    
    //EMPTY the new one (tested above
    DDID3Tag *tag2 = [DDID3Tag tagWithContentsOfFile: outputFilename];
    NSArray *allFrames = tag2.allFrames;
    int i = 0;
    while(i < allFrames.count){
        [tag2 removeFrame: allFrames[i]];
        i++;
    }
    [tag2 synchronize];
    
    //go through all frames and fields and manually clone them
    tag2 = [DDID3Tag emptyTag];
    for (DDID3Frame *frame in tag.allFrames) {
        DDID3Frame *newFrame = [DDID3Frame emptyFrame];
        assert(newFrame);
        
        newFrame.identifier = frame.identifier;
        newFrame.spec = frame.spec;
        
        //double check each field
        for (DDID3Field *field in frame.allFields) {
            DDID3Field *newField = [newFrame getField:field.identifier];
            assert(newField);
            assert(newField.type == field.type);
            newField.value = field.value;
            
        }
        
        [tag2 addFrame:newFrame];
    }
    
    //write the cloned tag
    tag2.fileName = outputFilename;
    [tag2 synchronize];

    //read back the tag
    tag = [DDID3Tag tagWithContentsOfFile:outputFilename];
    NSLog(@"%@", tag2);
    STAssertTrue([tag hasType:ID3TT_ID3V2], @"the test mp3 should have a id3 v2 tag");
    STAssertTrue(tag.allFrames.count==tag2.allFrames.count, @"the tag should have equal frames");
}

@end
