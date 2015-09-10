//
//  CrazyFileUtil.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrazyFileUtil : NSObject

#pragma mark - check file/directory existed

+ (BOOL)isFileExisted:(NSString *)filePath;

+ (BOOL)isDirectoryExisted:(NSString *)directory;

+ (BOOL)isPathExisted:(NSString *)path isDirectory:(BOOL *)isDirectory;

#pragma mark - file/directory handle

+ (BOOL)createDirectory:(NSString *)directory;

+ (BOOL)createFile:(NSString *)filePath overwrite:(BOOL)overwrite;

+ (BOOL)removeItem:(NSString *)itemPath;

+ (BOOL)copyItem:(NSString *)srcItemPath toPath:(NSString *)destItemPath;

+ (BOOL)moveItem:(NSString *)srcItemPath toPath:(NSString *)destItemPath;

#pragma mark - enum files in directory

+ (void)enumFilesInDirectory:(NSString *)directory
               callbackBlock:(void(^)(NSString * filePath))callbackBlock;

@end
