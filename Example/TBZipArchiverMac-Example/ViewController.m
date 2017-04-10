//
//  ViewController.m
//  TBZipArchiverMac-Example
//
//  Created by Bucha Kanstantsin on 4/10/17.
//  Copyright © 2017 truebucha. All rights reserved.
//

#import "ViewController.h"
#import <TBZipArchiver/TBZipArchiver.h>

#define TBZipArchiver_passphrase @"123"

@interface ViewController ()

@property (strong, nonatomic) TBZipArchiver * archiver;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL * URL = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory
                                                          inDomains: NSUserDomainMask] firstObject];
    NSLog(@"documents directory:\r%@", URL);
    
    NSURL * toArchive = [[[NSFileManager defaultManager] URLsForDirectory: NSDesktopDirectory
                                                                inDomains: NSUserDomainMask] firstObject];
    NSURL * destination = [URL URLByAppendingPathComponent:@"desktop.zip"];
    
    self.archiver = [[TBZipArchiver alloc] initWithFileURL: destination
                                                  password: TBZipArchiver_passphrase];
    
    [self.archiver createWithContentsOfDirecroty: toArchive
                               usingURLPredicate: nil
                                      completion: ^(NSError * _Nullable error) {
                                          if (error != nil) {
                                              NSLog(@"[ERROR] Failed to archive %@", error);
                                          } else {
                                              NSLog(@"Archived library to archive using passphrase %@", TBZipArchiver_passphrase);
                                              [self extractZipAtURL: destination passphrase: TBZipArchiver_passphrase];
                                          }
                                      }];
    // Do any additional setup after loading the view, typically from a nib.
}

/// MARK: - private -

- (void)extractZipAtURL:(NSURL *)URL passphrase:(NSString *)phrase {
    __block TBZipArchiver * archiver = [[TBZipArchiver alloc] initWithFileURL: URL
                                                                     password: phrase];
    NSURL * destination = [[URL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"Library"];
    [archiver extractContentsToDirectory: destination
                               overwrite: YES
                              completion: ^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"[ERROR] Failed to extract %@", error);
        } else {
            NSLog(@"Extracted content using passphrase %@", TBZipArchiver_passphrase);
        }
        archiver = nil;
    }];
}

@end
