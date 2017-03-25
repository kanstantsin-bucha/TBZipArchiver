

#import "TBFileManager.h"


#define TB_FileManager_SQLiteFile_Extension @".sqlite"


@implementation TBFileManager

/// MARK - public -

+ (void)cleanupSQLDatabaseFilesAtDirectory:(NSURL *)directory
                          usingFileManager:(NSFileManager *)manager {
    NSFileManager * currentManager = manager != nil ? manager
                                                    : [NSFileManager defaultManager];
    NSError * error = nil;
    NSArray * contents = [currentManager contentsOfDirectoryAtPath:directory.path
                                                             error:&error];
    if (error != nil) {
        NSLog(@"[ERROR] Failed to cleanup database files. Failed to get directory contents at %@", directory.path);
        return;
    }
    
    for (NSString * content in contents) {
        if ([content containsString:TB_FileManager_SQLiteFile_Extension]) {
            NSURL * contentURL = [directory URLByAppendingPathComponent:content];
            [currentManager removeItemAtURL:contentURL
                                      error:&error];
            if (error != nil) {
                NSLog(@"[ERROR] Failed to remove file at %@", contentURL.path);
                error = nil;
            }
        }
    }
}

+ (void)cleanupDirectory:(NSURL *)directory
        usingFileManager:(NSFileManager *)manager
                   error:(NSError **)error {
    NSFileManager * currentManager = manager != nil ? manager
                                                    : [NSFileManager defaultManager];
    [currentManager removeItemAtURL:directory
                              error:error];
    if (*error != nil) {
        return;
    }
    
    [currentManager createDirectoryAtURL:directory
             withIntermediateDirectories:YES
                              attributes:nil
                                   error:error];
}

+ (void)copyContentsOfDirectory:(NSURL *)fromDirectory
                    toDirectory:(NSURL *)toDirectory
               usingFileManager:(NSFileManager *)manager
                          error:(NSError **)error {
    NSFileManager * currentManager = manager != nil ? manager
                                                    : [NSFileManager defaultManager];
    
    NSArray * contents = [currentManager contentsOfDirectoryAtPath:fromDirectory.path
                                                             error:error];
    if (*error != nil) {
        return;
    }
    
    for (NSString * content in contents) {
        NSURL * source = [fromDirectory URLByAppendingPathComponent:content];
        NSURL * destination = [toDirectory URLByAppendingPathComponent:content];
        [currentManager copyItemAtURL:source
                                toURL:destination
                                error:error];
        if (*error != nil) {
            return;
        }
    }
}

+ (void)createPathToDirectory:(NSURL *)directory
             usingFileManager:(NSFileManager *)manager {
    NSFileManager * currentManager = manager != nil ? manager
                                                    : [NSFileManager defaultManager];
    
    TBFileItemType type = [self typeOfItemAtURL:directory
                               usingFileManager:currentManager];
    
    if (type == TBFileItemDirectory) {
        return;
    }
    
    
    NSError * error = nil;
    if (type == TBFileItemFile) {
        
        [currentManager removeItemAtURL:directory
                                  error:&error];
        if (error != nil) {
            NSLog(@"[ERROR] Failed to remove file that placed instead directory at %@", directory);
        }
    }
    
    [currentManager createDirectoryAtURL:directory
             withIntermediateDirectories:YES
                              attributes:nil
                                   error:nil];
    
    if (error != nil) {
        NSLog(@"[ERROR] Failed to create path %@", directory);
    }
}

+ (TBFileItemType)typeOfItemAtURL:(NSURL *)itemURL
                 usingFileManager:(NSFileManager *)manager {
    NSFileManager * currentManager = manager != nil ? manager
                                                    : [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [currentManager fileExistsAtPath:itemURL.path
                                       isDirectory:&isDirectory];
    
    TBFileItemType result = TBFileItemNotExists;
    if (exists) {
        result = isDirectory ? TBFileItemDirectory
                             : TBFileItemFile;
    }
    
    return result;
}

+ (void)enumerateContentsOfDirectory:(NSURL *)directory
                   usingURLPredicate:(NSPredicate *)URLPredicate
                         fileManager:(NSFileManager *)manager
                    enumerationBlock:(TBDirectoryContentsEnumeration _Nonnull )block {
    
    NSFileManager * currentManager = manager != nil ? manager
                                                    : [NSFileManager defaultManager];
    NSError * error = nil;
    NSArray * contents = [currentManager contentsOfDirectoryAtPath:directory.path
                                                             error:&error];
    if (error != nil) {
        NSLog(@"[ERROR] Failed to get directory contents at %@", directory.path);
        return;
    }
    
    BOOL stop = NO;
    for (NSString * item in contents) {
        NSURL * itemURL = [directory URLByAppendingPathComponent:item];
        
        BOOL shouldProcess = YES;
        
        if (URLPredicate != nil) {
            shouldProcess = [URLPredicate evaluateWithObject:itemURL];
        }
        
        if (shouldProcess == NO) {
            continue;
        }

        TBFileItemType type = [self typeOfItemAtURL:itemURL
                                   usingFileManager:currentManager];
        block(itemURL, type, &stop);
        if (stop) {
            return;
        }
    }
}

+ (void)cleanupContentsOfDirectory:(NSURL *)directory
                  usingFileManager:(NSFileManager *)manager
                removeURLPredicate:(NSPredicate *)predicate
                             error:(NSError **)error {
    [TBFileManager enumerateContentsOfDirectory:directory
                               usingURLPredicate:predicate
                                     fileManager:manager
                                enumerationBlock:^(NSURL * _Nonnull itemURL, TBFileItemType itemType, BOOL * _Nonnull stop) {
        NSError * removeError = nil;
        [manager removeItemAtURL:itemURL
                           error:&removeError];
        if (removeError != nil) {
            *error = removeError;
        }
    }];
}


+ (void)copySourceDirectory:(NSURL *)source
toDestinationDirectoryAtURL:(NSURL *)destination
                  overwrite:(BOOL)overwrite
           usingFileManager:(NSFileManager *)manager
                      error:(NSError **)error {
    NSFileManager * currentManager = manager != nil ? manager
                                                    : [NSFileManager defaultManager];
    TBFileItemType type = [self typeOfItemAtURL:destination
                               usingFileManager:currentManager];
    
    if (type != TBFileItemNotExists && overwrite == NO) {
        return;
    }
    
    if (type == TBFileItemFile
        || (type == TBFileItemDirectory && overwrite)) {
        
        [currentManager removeItemAtURL:destination
                                  error:error];
        if (*error != nil) {
            return;
        }
    }
    
    [currentManager copyItemAtURL:source
                            toURL:destination
                            error:error];
}

+ (BOOL)isEmptyDirectoryAtURL:(NSURL *)directory
             usingFileManager:(NSFileManager *)manager {
    NSFileManager * currentManager = manager != nil ? manager
                                                    : [NSFileManager defaultManager];
    TBFileItemType type = [self typeOfItemAtURL:directory
                               usingFileManager:currentManager];
    
    if (type != TBFileItemDirectory) {
        return NO;
    }
    
    __block BOOL result = YES;
    [TBFileManager enumerateContentsOfDirectory:directory
                               usingURLPredicate:nil
                                     fileManager:manager
                               enumerationBlock:^(NSURL *itemURL, TBFileItemType itemType, BOOL *stop) {
       result = NO;
       *stop = YES;
    }];
    return result;
}

+ (void)copySQLDatabaseAtURL:(NSURL *)sourceDatabase
                       toURL:(NSURL *)destinationDatabase
            usingFileManager:(NSFileManager *)manager
                       error:(NSError **)error {   
    NSFileManager * currentManager = manager != nil ? manager
                                                    : [NSFileManager defaultManager];
    TBFileItemType type = [self typeOfItemAtURL:sourceDatabase
                               usingFileManager:currentManager];
    
    if (type != TBFileItemFile
        || [[sourceDatabase.path lastPathComponent] containsString:TB_FileManager_SQLiteFile_Extension] == NO) {
        *error = [self wrongFileErrorWithFileDescription:@"SQL database"];
        return;
    }
    
    NSURL * sourceDirectory = [sourceDatabase URLByDeletingLastPathComponent];
    NSString * sourceFileName = [[sourceDatabase.path lastPathComponent] stringByDeletingPathExtension];
    NSURL * destinationDirectory = [destinationDatabase URLByDeletingLastPathComponent];
    NSString * destinationFileName = [[destinationDatabase.path lastPathComponent] stringByDeletingPathExtension];
    
    [self enumerateContentsOfDirectory:sourceDirectory
                     usingURLPredicate:nil
                           fileManager:currentManager
                      enumerationBlock:^(NSURL *itemURL, TBFileItemType itemType, BOOL *stop) {
        NSString * filenameWithExtention = [itemURL.path lastPathComponent];
        NSString * filename = [filenameWithExtention stringByDeletingPathExtension];
        if ([filename isEqualToString:sourceFileName] == NO) {
            return;
        }
        NSString * extention = [filenameWithExtention pathExtension];
        NSString * destinationFile = [destinationFileName stringByAppendingPathExtension:extention];
        NSURL * destinationURL = [destinationDirectory URLByAppendingPathComponent:destinationFile];
            [currentManager copyItemAtURL:itemURL
                                    toURL:destinationURL
                                    error:error];
            if (error != nil) {
                *stop = YES;
                return;
            }
    }];
}

/// MARK - private -

/// MARK: error

+ (NSError *)wrongFileErrorWithFileDescription:(NSString *)description {
    NSString * message = [NSString stringWithFormat: @"Provided nil or wrong %@ file.", description];
    NSError * result = [NSError errorWithDomain:NSStringFromClass([self class])
                                           code:2
                                       userInfo:@{NSLocalizedDescriptionKey : message}];
    return result;
}

@end
