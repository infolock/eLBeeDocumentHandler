//
//  eLBeeDocumentHandler.h
//
// Heavily based on Justin Driscoll's Single Shared UIManagedDocument article:
// http://www.adevelopingstory.com/blog/2012/03/core-data-with-a-single-shared-uimanageddocument.html
//
//  Created by Jonathon Hibbard on 1/24/13.
//  Copyright (c) 2013 Integrated Events. All rights reserved.
//
//  This code is released under the MIT License.  See LICENSE for more information.

#import <Foundation/Foundation.h>

typedef void (^OnDocumentReady) (UIManagedDocument *document);

@interface eLBeeDocumentHandler : NSObject

@property (strong, nonatomic) UIManagedDocument *document;

+(eLBeeDocumentHandler *)sharedDocumentHandler;
-(void)performWithDocument:(OnDocumentReady)onDocumentReady;

@end
