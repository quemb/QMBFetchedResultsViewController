//
//  QMBFetchedResultsViewController.m
//  Bautagebuch
//
//  Created by Toni Möckel on 21.11.12.
//  Copyright (c) 2012 Toni Möckel. All rights reserved.
//

#import "QMBFetchedResultsViewController.h"

@interface QMBFetchedResultsViewController (){
    NSIndexPath* _lastDeleteItemIndexPathAsked;
}


@end

@implementation QMBFetchedResultsViewController

@synthesize tableView = _tableView;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObject = _managedObject;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
}

- (NSManagedObjectContext *)managedObjectContext{
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = object.description;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete", nil) message:NSLocalizedString(@"Are you sure to delete this entry?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Delete", nil), nil];
        alert.tag = 666; // Evil
        [alert show];
        
        _lastDeleteItemIndexPathAsked = indexPath;
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 666){
        if (buttonIndex == 1)
        {
            // Delete the row from the data source
            // Delete the managed object at the given index path.
            NSManagedObject* objectToDelete = [self.fetchedResultsController objectAtIndexPath:_lastDeleteItemIndexPathAsked];
            [self.managedObjectContext deleteObject:objectToDelete];
            
            // Commit the change.
            NSError* error;
            if (![self.managedObjectContext save:&error])
            {
                // Handle the error.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                exit(-1);
            }
            //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        return;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSFetchedResultsController Methods

/**
 * Use this method for you custom fetch request:
 *
 * NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
 * NSEntityDescription *entity = [NSEntityDescription
 * entityForName:@"Entity" inManagedObjectContext:self.managedObjectContext];
 * [fetchRequest setEntity:entity];
 
 * [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"otherEntity == %@", self.managedObject]];
 
 * NSSortDescriptor *sort = [[NSSortDescriptor alloc]
 * initWithKey:@"date" ascending:NO];
 * [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
 *
 **/

- (NSFetchRequest *) getFetchRequest{
    
    return nil;
}

/**
 * Use this if your fetch result should support sections
 * This is optional
 * Return the entity attribute key
 */

- (NSString *) getSectionKeyPath{
    return nil;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [self getFetchRequest];
    
    NSAssert(fetchRequest!=nil,@"No Fetch Request");
    NSAssert([self managedObjectContext]!=nil,@"No Managed Object");
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[self managedObjectContext]
                                          sectionNameKeyPath:[self getSectionKeyPath]
                                                   cacheName:nil];
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    
    return _fetchedResultsController;
    
}

@end
