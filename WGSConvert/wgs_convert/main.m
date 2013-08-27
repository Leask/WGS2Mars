//
//  main.m
//  wgs_convert
//
//  Created by 0day on 13-8-26.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct offset_data {
    int16_t lng;    //12151表示121.51
    int16_t lat;    //3130表示31.30
    int16_t x_off;  //地图x轴偏移像素值
    int16_t y_off;  //地图y轴偏移像素值
} offset_data;

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        if (argc != 3) {
            NSLog(@"argv error. eg. './wgs_convert input output'");
            return 1;
        }
        
        NSString *sourcePath = [[NSString stringWithFormat:@"%s", argv[1]] stringByExpandingTildeInPath];
        NSString *destinationPath = [[NSString stringWithFormat:@"%s", argv[2]] stringByExpandingTildeInPath];
        
        NSData *sourceData = [NSData dataWithContentsOfFile:sourcePath options:NSDataReadingMappedIfSafe error:NULL];
        
        const void *buffer = [sourceData bytes];
        long long bufferLength = sourceData.length;
        long long count = bufferLength / sizeof(offset_data);
        long long i = 0;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
            [[NSFileManager defaultManager] createFileAtPath:destinationPath
                                                    contents:nil
                                                  attributes:nil];
        }
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:destinationPath];
        
        NSLog(@"start");
        while (count) {
            offset_data *offset = (offset_data *)malloc(sizeof(offset_data));
            
            memset(offset, 0, sizeof(offset_data));
            memcpy(offset, buffer + i * sizeof(offset_data), sizeof(offset_data));
            
            NSString *offsetString = [NSString stringWithFormat:@"%d,%d,%d,%d\n", offset->lng, offset->lat, offset->x_off, offset->y_off];
            NSData *data = [offsetString dataUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@", offsetString);
            
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
            
            free(offset);
            ++i;
            --count;
        }
        NSLog(@"end");
    }
    
    return 0;
}

