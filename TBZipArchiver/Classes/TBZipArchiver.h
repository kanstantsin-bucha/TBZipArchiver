

#import <Foundation/Foundation.h>
#import <CDBKit/CDBKit.h>


@interface TBZipArchiver : NSObject

@property (strong, nonatomic, readonly) NSURL * _Nullable fileURL;

- (instancetype _Nullable)initWithFileURL:(NSURL * _Nonnull)URL
                                 password:(NSString * _Nullable)password;

- (void)extractContentsToDirectory:(NSURL * _Nonnull)directory
                         overwrite:(BOOL)overwrite
                        completion:(CDBErrorCompletion _Nonnull)completion;
- (void)createWithContentsOfDirecroty:(NSURL * _Nonnull)directory
                    usingURLPredicate:(NSPredicate * _Nullable)URLPredicate
                           completion:(CDBErrorCompletion _Nonnull)completion;

@end
