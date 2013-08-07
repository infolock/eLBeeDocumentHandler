eLBeeDocumentHandler
====================

## About
This is a small UIManagedDocument handler I use for working with UIManagedDocument and Core Data.  

It is based heavily on an article (and code) written by Justin Driscoll, ["Core Data with a Single Shared UIManagedDocument"](http://www.adevelopingstory.com/blog/2012/03/core-data-with-a-single-shared-uimanageddocument.html).

The modifications I made to his original code were out of my own personal needs.  I wanted to be able to use this class at any stage, but unfortunately there was a small (and yet significant) lag/blocking of the main thread that was preventing views from painting until the document was fully loaded.

To fix this issue, I implemented some (probably nasty) tweaks in order to get around this.  I'm releasing this code because it works like a champ for me so thought I'd share.  The other (and more important) reason is to get any feedback possible from other developers in how this can be further improved.

## Example Usage

First of all, you should really read Justin's article listed above for a good introduction of what this handler does and also why it is even needed.

When you get that down, you'll want to realize that the implementation and usage of the version I've created is just a tad different.  It is as follows:


#### MyTableViewController.h
```objective-c
@interface MyTableViewController : CoreDataTVCDelegate

// The selected "person" from the People collection (core data fetched object).
// This TableViewController will have been passed the "People" object from a different controller (at least in this instance it was)
@property (nonatomic, strong) People *person;

@end

```


#### MyTableViewController.m
```objective-c

#import "MyTableViewController.h"
#import "eLBeeDocumentHandler.h"

@interface ListItemTableViewController ()

@property (nonatomic, strong) UIManagedDocument *document;

@end



@implementation MyTableViewController

#pragma mark -
#pragma mark Constructors and Destructors
#pragma mark -

-(void)viewDidLoad {
    [super viewDidLoad];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MyCell"];
}

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self useDocument];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.document.managedObjectContext refreshObject:self.myList mergeChanges:self.document.managedObjectContext.hasChanges];
}

-(void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Setters, Updaters, etc.
#pragma mark -

-(void)setPeople:(People *)person {
    if(!_person) {
        _person = person;
        self.title = person.name;
    }
}


-(void)setDocument:(UIManagedDocument *)document {
    if(!_document || ![_document isEqual:document]) {
        _document = document;
    }

//    [self setupFetchedResultsController];
//    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Core Data
#pragma mark -


#pragma mark UIManagedDocument Control Methods

-(void)useDocument {

    if(self.document && [self.document.managedObjectContext hasChanges]) {
        [self saveDocument];
    }

    MyTableViewController *__weak weakSelf = self;
    dispatch_queue_t queue;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [[eLBeeDocumentHandler sharedDocumentHandler] performWithDocument:^(UIManagedDocument *document) {
            if(document) {
               // Keeping the document on the main thread (and anything that maybe on the main thread the setter may interact with - like a tableview ..)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf setDocument:document];
                });
            }
        }];
    });
}

/* All of your tableview controller logic goes here.... just using self.document or self.person as needed... */

@end

```
