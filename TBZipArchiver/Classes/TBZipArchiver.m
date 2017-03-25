

#import "TBZipArchiver.h"
#import "TBFileManager.h"
#import <ZipArchive/ZipArchive.h>
#import <TBFileManager/TBFileManager.h>


@interface TBZipArchiver ()

@property (strong, nonatomic, readwrite) NSURL * fileURL;
@property (copy, nonatomic, readwrite) NSString * password;

@end


@implementation TBZipArchiver

/// MARK: - Property -

/// MARK: Getter

- (NSError *)failedCreateFileErrorUsingPath:(NSString *)path {
    NSDictionary * info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Failed to create file at provided path %@", path]};
    NSError * result = [NSError errorWithDomain:NSStringFromClass([self class])
                                           code:0
                                       userInfo:info];
    return result;
}

- (NSError *)failedAddFileErrorUsingPath:(NSString *)path {
    NSDictionary * info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Failed to add file at path %@", path]};
    NSError * result = [NSError errorWithDomain:NSStringFromClass([self class])
                                           code:1
                                       userInfo:info];
    return result;
}

- (NSError *)failedOpenFileErrorUsingPath:(NSString *)path {
    NSDictionary * info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Failed to open file at provided path %@", path]};
    NSError * result = [NSError errorWithDomain:NSStringFromClass([self class])
                                           code:2
                                       userInfo:info];
    return result;
}

- (NSError *)failedExtractFilesErrorUsingPath:(NSString *)path {
    NSDictionary * info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Failed to extract files to path %@", path]};
    NSError * result = [NSError errorWithDomain:NSStringFromClass([self class])
                                           code:3
                                       userInfo:info];
    return result;
}


/// MARK: - Life cycle - 

- (instancetype)initWithFileURL:(NSURL *)URL
                       password:(NSString *)password {
    self = [super init];
    if (self) {
        _password = password;
        _fileURL = URL;
    }
    return self;
}


/// MARK: - Public - 

- (void)extractContentsToDirectory:(NSURL *)directory
                         overwrite:(BOOL)overwrite
                        completion:(CDBErrorCompletion)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager * manager = [[NSFileManager alloc] init];
        ZipArchive * archivator = [[ZipArchive alloc] initWithFileManager:manager];
        [TBFileManager createPathToDirectory:directory
                             usingFileManager:manager];
        if (overwrite) {
            NSError * error = nil;
            [TBFileManager cleanupDirectory:directory
                            usingFileManager:manager
                            error:&error];
            if (error != nil) {
                NSLog(@"[ERROR] Failed to overwrite existed directory at URL\
                \r| %@\
                \r| error:\
                \r| %@",
                directory, error);
            }
        }
        
        BOOL unzipped = [archivator UnzipOpenFile:self.fileURL.path
                                         Password:self.password];
        if (unzipped == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([self failedOpenFileErrorUsingPath:self.fileURL.path]);
            });
        }
        unzipped = [archivator UnzipFileTo:directory.path
                                 overWrite:overwrite];
        if (unzipped == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([self failedExtractFilesErrorUsingPath:directory.path]);
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
    });
}

- (void)createWithContentsOfDirecroty:(NSURL *)directory
                    usingURLPredicate:(NSPredicate *)URLPredicate
                           completion:(CDBErrorCompletion)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager * manager = [[NSFileManager alloc] init];
        ZipArchive * archivator = [[ZipArchive alloc] initWithFileManager:manager];
        archivator.compression = ZipArchiveCompressionBest;
        
        NSURL * fileDirectory = [self.fileURL URLByDeletingLastPathComponent];
        [TBFileManager createPathToDirectory:fileDirectory
                             usingFileManager:manager];
        
        BOOL result = YES;
        result = [archivator CreateZipFile2:self.fileURL.path
                                   Password:self.password];
        
        if (result == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([self failedCreateFileErrorUsingPath:self.fileURL.path]);
            });
            return;
        }
        
        NSError * error = nil;
        
        [self addContentsOfDirectory:directory
                   usingURLPredicate:URLPredicate
                        archivedPath:nil
                          archivator:archivator
                         fileManager:manager
                               error:&error];
        
        if (error != nil) {
            [archivator CloseZipFile2];
            [self cleanupFileAtURL:self.fileURL
                      usingManager:manager];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([self failedCreateFileErrorUsingPath:self.fileURL.path]);
            });
            return;
        }
        
        [archivator CloseZipFile2];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
    });
}

/// MARK: - Private -

- (void)addContentsOfDirectory:(NSURL *)directory
             usingURLPredicate:(NSPredicate *)URLPredicate
                  archivedPath:(NSString *)archivedPath
                    archivator:(ZipArchive *)archivator
                   fileManager:(NSFileManager *)manager
                         error:(NSError **)error {
    NSString * currentArchivedPath = archivedPath != nil ? archivedPath
                                                         : @"";
    [TBFileManager createPathToDirectory:directory
                         usingFileManager:manager];
    [TBFileManager enumerateContentsOfDirectory:directory
                               usingURLPredicate:URLPredicate
                                     fileManager:manager
                                enumerationBlock:^(NSURL *itemURL, TBFileItemType itemType, BOOL *stop) {
        NSString * archivedItemPath =
            [currentArchivedPath stringByAppendingPathComponent:itemURL.path.lastPathComponent];
            
        if (itemType == TBFileItemDirectory) {
            [self addContentsOfDirectory:itemURL
                       usingURLPredicate:URLPredicate
                            archivedPath:archivedItemPath
                              archivator:archivator
                             fileManager:manager
                                   error:error];
            if (*error != nil) {
                *stop = YES;
                return;
            }
            return;
        }
        
        BOOL added =
            [archivator addFileToZip:itemURL.path
                             newname:archivedItemPath];
        if (added == NO) {
            *error = [self failedAddFileErrorUsingPath:itemURL.path];
            *stop = YES;
            return;
        }
    }];
}

- (void)cleanupFileAtURL:(NSURL *)fileURL
            usingManager:(NSFileManager *)manager {
    NSError * error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL
                                              error:&error];
    
    if (error != nil) {
        NSLog(@"[ERROR] Failed to cleanup item at %@", fileURL.path);
    }
}


@end
