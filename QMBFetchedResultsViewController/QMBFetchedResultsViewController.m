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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
	[self performFetch];
    
    
}

- (void) performFetch
{
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onEnterEditMode:(id)sender{
    if ([self.tableView isEditing]) {
        // If the tableView is already in edit mode, turn it off. Also change the title of the button to reflect the intended verb (‘Edit’, in this case).
        if ([sender class] == [UIButton class]){
            [(UIButton *)sender setImage:[UIImage imageNamed:@"icon_edit_header_information"] forState:UIControlStateNormal];
        }
        [self.tableView setEditing:NO animated:YES];
    }
    else {
        [(UIButton *)sender setImage:[UIImage imageNamed:@"menubar_save"] forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];
    }
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
    if (tableView == _tableView)
    {
        return [[self.fetchedResultsController sections] count] + [self sectionOffset];
        
    }else {
        
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section - [self sectionOffset]];
    
    return [sectionInfo numberOfObjects] + [self rowOffset];
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (NSString *) cellIdentifierForIndexPath:(NSIndexPath *)indexPath{
    return @"Cell";
}

- (UITableViewCellStyle) cellStyleForIndexPath:(NSIndexPath *) indexPath {
    return UITableViewCellStyleDefault;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:[self cellStyleForIndexPath:indexPath] reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row+[self rowOffset] inSection:newIndexPath.section + [self sectionOffset]];
    
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
    
    sectionIndex = sectionIndex + [self sectionOffset];
    
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete", nil) message:NSLocalizedString(@"Sind Sie sicher, dass sie diesen Eintag löschen möchten?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Delete", nil), nil];
        alert.tag = 666; //Evel Delete Alert (damit die Kinderklassen auch noch alerten können)
        [alert show];
        
        _lastDeleteItemIndexPathAsked = [NSIndexPath indexPathForRow:indexPath.row+[self rowOffset] inSection:indexPath.section+[self sectionOffset]];
        
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
            [objectToDelete.managedObjectContext deleteObject:objectToDelete];
            
            // Commit the change.
            NSError* error;
            if (![objectToDelete.managedObjectContext save:&error])
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
    indexPath = [NSIndexPath indexPathForRow:indexPath.row+[self rowOffset] inSection:indexPath.section+[self sectionOffset]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSFetchedResultsController

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-[self rowOffset] inSection:indexPath.section-[self sectionOffset]]];
}

- (NSUInteger)fetchBatchSize
{
    return 0;
}

- (NSUInteger)fetchLimit {
    return 0;
}

- (NSPredicate *)fetchPredicate {
    return nil;
}

- (NSFetchRequest *) fetchRequest{
    
    //request
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    //entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //predicate
    NSPredicate *predicate = [self fetchPredicate];
    if (predicate)
        [fetchRequest setPredicate:predicate];
    
    //sort descriptors
    NSArray *sortDescriptors = [self sortDescriptors];
    
    if (!sortDescriptors || [sortDescriptors count] == 0)
    {
        NSArray *sortKeys = [self sortKeys];
        
        if (sortKeys && [sortKeys count] > 0)
        {
            NSMutableArray *descriptors = [NSMutableArray new];
            
            for (NSString *key in sortKeys)
            {
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
                [descriptors addObject:sortDescriptor];
            }
            
            sortDescriptors = [NSArray arrayWithArray:descriptors];
        }
    }
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    if ([self fetchLimit] > 0){
        [fetchRequest setFetchLimit:[self fetchLimit]];
    }
    
    //batch size
    [fetchRequest setFetchBatchSize:[self fetchBatchSize]];
    
    return fetchRequest;
}

- (NSString *)entityName
{
    return nil;
}


- (NSArray *)sortDescriptors
{
    return nil;
}


- (NSArray *)sortKeys
{
    return nil;
}

- (NSString *) sectionKeyPath{
    return nil;
}

- (NSUInteger) sectionOffset {
    return 0;
}

- (NSUInteger) rowOffset {
    return 0;
}

- (NSString *)cacheName {
    return nil;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [self fetchRequest];
    
    NSAssert(fetchRequest!=nil,@"No Fetch Request");
    NSAssert([self managedObjectContext]!=nil,@"No Managed Object");
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[self managedObjectContext]
                                          sectionNameKeyPath:[self sectionKeyPath]
                                                   cacheName:[self cacheName]];
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    
    return _fetchedResultsController;
    
}




@end
