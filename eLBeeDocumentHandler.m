//
//  eLBeeDocumentHandler.m
//
// Heavily based on Justin Driscoll's Single Shared UIManagedDocument article:
// http://www.adevelopingstory.com/blog/2012/03/core-data-with-a-single-shared-uimanageddocument.html
//
//  Created by Jonathon Hibbard on 1/24/13.
//  Copyright (c) 2013 Integrated Events. All rights reserved.
//
//  This code is released under the MIT License.  See LICENSE for more information.

#import "eLBeeDocumentHandler.h"

//static NSString *const eLBeeCloudContentNameKey = @"com.integratedevents.elbee.mylistdata";
static NSString *const eLBeePathComponent = @"eLBeeDocument_v6_4.md";


@interface eLBeeDocumentHandler () <UIAlertViewDelegate>

-(void)objectsDidChange:(NSNotification *)notification;
-(void)contextDidSave:(NSNotification *)notification;

@end


@implementation eLBeeDocumentHandler

+(eLBeeDocumentHandler *)sharedDocumentHandler {
    
    __strong static eLBeeDocumentHandler *sharedInstance = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [eLBeeDocumentHandler new];
    });
    
    return sharedInstance;
}

-(id)init {
    
    self = [super init];
    if(self) {

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, eLBeePathComponent];
        NSURL *noCloudURL = [NSURL fileURLWithPath:path];

        NSMutableDictionary *options = [NSMutableDictionary dictionary];

        [options setValue:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
        [options setValue:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
        [options setValue:[NSNumber numberWithBool:YES] forKey:NSIgnorePersistentStoreVersioningOption];

        dispatch_sync(dispatch_get_main_queue(), ^{

            // Remove this guy when we get iCloud support back, since we'll be assigning and defining UIManagedDocument below..
            self.document = [[UIManagedDocument alloc] initWithFileURL:noCloudURL];
            self.document.persistentStoreOptions = options;

            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(objectsDidChange:)
                                                         name:NSManagedObjectContextObjectsDidChangeNotification
                                                       object:self.document.managedObjectContext];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(contextDidSave:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:self.document.managedObjectContext];
        });


    }
    return self;
}

// Blocks for the win!
-(void)performWithDocument:(OnDocumentReady)onDocumentReady {

    void (^OnDocumentDidLoad)(BOOL) = ^(BOOL success) {
        onDocumentReady(self.document);
//         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedDocumentUpdated:) name:@"managedDocumentUpdated" object:nil];
    };

    NSURL *fileURL = self.document.fileURL;
    if(![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
            [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:OnDocumentDidLoad];
    } else if(self.document.documentState == UIDocumentStateClosed) {
        [self.document openWithCompletionHandler:OnDocumentDidLoad];
    } else if(self.document.documentState == UIDocumentStateNormal) {
        OnDocumentDidLoad(YES);
    }
}

-(void)objectsDidChange:(NSNotification *)notification {
    //    NSLog(@">>>>>>>>>>> NSManagedObjects did change.  Notification = %@ <<<<<<<<<<<", [notification debugDescription]);
}

-(void)contextDidSave:(NSNotification *)notification {
    //    NSLog(@">>>>>>>>>>> NSManagedObjects did save.  Notification = %@  <<<<<<<<<<<", [notification debugDescription]);
}


@end

