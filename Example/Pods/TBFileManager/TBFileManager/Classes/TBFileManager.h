

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, TBFileItemType) {
    TBFileItemNotExists = 0,
    TBFileItemDirectory = 1,
    TBFileItemFile = 2
};


typedef void (^TBDirectoryContentsEnumeration) (NSURL * _Nonnull itemURL, TBFileItemType itemType, BOOL * _Nonnull stop);


@interface TBFileManager : NSObject

+ (void)cleanupDirectory:(NSURL * _Nonnull)directory
        usingFileManager:(NSFileManager * _Nullable)manager
                   error:(NSError * _Nullable * _Nullable)error;
+ (void)cleanupSQLDatabaseFilesAtDirectory:(NSURL * _Nonnull)directory
                          usingFileManager:(NSFileManager * _Nullable)manager;
+ (void)copySQLDatabaseAtURL:(NSURL * _Nonnull)sourceDatabase
                       toURL:(NSURL * _Nonnull)destinationDatabase
            usingFileManager:(NSFileManager * _Nullable)manager
                       error:(NSError * _Nullable * _Nullable)error ;

+ (void)copyContentsOfDirectory:(NSURL * _Nonnull)fromDirectory
                    toDirectory:(NSURL * _Nonnull)toDirectory
               usingFileManager:(NSFileManager * _Nullable)manager
                          error:(NSError * _Nullable * _Nullable)error;
/**
 create a directory at URL if no presents

 @param directory directory URL
 @param force override if a file presents at URL istead of directory
 @param manager using provided fileManager
 */

+ (void)createPathToDirectory:(NSURL * _Nonnull)directory
                        force:(BOOL)force
             usingFileManager:(NSFileManager * _Nullable)manager;

+ (TBFileItemType)typeOfItemAtURL:(NSURL * _Nonnull)itemURL
                 usingFileManager:(NSFileManager * _Nullable)manager;

+ (void)enumerateContentsOfDirectory:(NSURL * _Nonnull)directory
                   usingURLPredicate:(NSPredicate * _Nullable)URLPredicate
                         fileManager:(NSFileManager * _Nullable)manager
                    enumerationBlock:(TBDirectoryContentsEnumeration _Nonnull)block;
+ (void)cleanupContentsOfDirectory:(NSURL * _Nonnull)directory
                  usingFileManager:(NSFileManager * _Nullable)manager
                removeURLPredicate:(NSPredicate * _Nonnull)predicate
                             error:(NSError * _Nullable * _Nullable)error;

+ (void)copySourceDirectory:(NSURL * _Nonnull)source
toDestinationDirectoryAtURL:(NSURL * _Nonnull)destination
                  overwrite:(BOOL)overwrite
           usingFileManager:(NSFileManager * _Nullable)manager
                      error:(NSError * _Nullable * _Nullable)error;

+ (BOOL)isEmptyDirectoryAtURL:(NSURL * _Nonnull)directory
             usingFileManager:(NSFileManager * _Nullable)manager;

@end
