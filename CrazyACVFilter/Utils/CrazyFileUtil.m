//
//  CrazyFileUtil.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyFileUtil.h"

@implementation CrazyFileUtil

#pragma mark - check file/directory existed

+ (BOOL)isFileExisted:(NSString *)filePath
{
    BOOL isDirectory = NO;
    BOOL isExisted   = [CrazyFileUtil isPathExisted:filePath isDirectory:&isDirectory];
    if (YES == isExisted && NO == isDirectory) {
        return YES;
    }
    return NO;
}

+ (BOOL)isDirectoryExisted:(NSString *)directory
{
    BOOL isDirectory = YES;
    BOOL isExisted   = [CrazyFileUtil isPathExisted:directory isDirectory:&isDirectory];
    if (YES == isExisted && YES == isDirectory) {
        return YES;
    }
    return NO;
}

+ (BOOL)isPathExisted:(NSString *)path isDirectory:(BOOL *)isDirectory
{
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    return [fileMgr fileExistsAtPath:path isDirectory:isDirectory];
}

#pragma mark - file/directory handle

+ (BOOL)createDirectory:(NSString *)directory
{
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    
    NSError * error = nil;
    BOOL result = [fileMgr createDirectoryAtPath:directory
                     withIntermediateDirectories:YES attributes:nil error:&error];
    if (YES == result && nil == error) {
        return YES;
    } else {
        CrazyLogw(@"create directory[%@] failed", directory);
        return NO;
    }
}

+ (BOOL)createFile:(NSString *)filePath overwrite:(BOOL)overwrite
{
    if ([filePath hasSuffix:@"/"]) {
        CrazyLogw(@"create file[%@] failed, may be it is a directory", filePath);
        return NO;
    }
    
    if (NO == overwrite && YES == [self isFileExisted:filePath]) {
        CrazyLogi(@"create file[%@] with overwrite[%@] successfully", filePath, @(overwrite));
        return YES;
    }
    
    NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
    if (NSNotFound != range.location) {
        NSString * folder = [filePath substringToIndex:(range.location + 1)];
        [self createDirectory:folder];
    }
    
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    if (YES == [fileMgr createFileAtPath:filePath contents:nil attributes:nil]) {
        CrazyLogi(@"create file[%@] with overwrite[%@] successfully", filePath, @(overwrite));
        return YES;
    } else {
        CrazyLogw(@"create file[%@] with overwrite[%@] failed", filePath, @(overwrite));
        return NO;
    }
}

+ (BOOL)removeItem:(NSString *)itemPath
{
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    
    NSError * error = nil;
    BOOL result = [fileMgr removeItemAtPath:itemPath error:&error];
    if (YES == result && nil == error) {
        return YES;
    } else {
        CrazyLogw(@"remove file/directory[%@] failed", itemPath);
        return NO;
    }
}

+ (BOOL)copyItem:(NSString *)srcItemPath toPath:(NSString *)destItemPath
{
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    
    NSError * error = nil;
    BOOL result = [fileMgr copyItemAtPath:srcItemPath
                                   toPath:destItemPath error:&error];
    if (YES == result && nil == error) {
        return YES;
    } else {
        CrazyLogw(@"copy file/directory[%@] to path[%@] failed", srcItemPath, destItemPath);
        return NO;
    }
}

+ (BOOL)moveItem:(NSString *)srcItemPath toPath:(NSString *)destItemPath
{
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    
    NSError * error = nil;
    BOOL result = [fileMgr moveItemAtPath:srcItemPath
                                   toPath:destItemPath error:&error];
    if (YES == result && nil == error) {
        return YES;
    } else {
        CrazyLogw(@"move file/directory[%@] to path[%@] failed", srcItemPath, destItemPath);
        return NO;
    }
}

#pragma mark - enum file in directory

+ (void)enumFilesInDirectory:(NSString *)directory
               callbackBlock:(void(^)(NSString * filePath))callbackBlock
{
    if (NO == [self isDirectoryExisted:directory]) {
        CrazyLoge(@"enumFilesInDirectory failed, the directory[%@] isn't existed", directory);
        return;
    }
    
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator * enumerator = [fileMgr enumeratorAtPath:directory];
    for (NSString * fileItem = enumerator.nextObject; nil != fileItem;)
    {
        if (0 != fileItem.length) {
            callbackBlock([directory stringByAppendingPathComponent:fileItem]);
        }
        fileItem = enumerator.nextObject;
    }
}

@end
