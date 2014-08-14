// DataManager.m
#import "DataManager.h"

@interface DataManager ()

- (NSString*)sharedDocumentsPath;

@end

@implementation DataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize objectModel = _objectModel;

NSString * const kDataManagerBundleName = @"sfdatamodels";
NSString * const kDataManagerModelName = @"sfdatamodel";
NSString * const kDataManagerSQLiteName = @"sfdata.sqlite";

+ (DataManager *)sharedInstance
{
	static dispatch_once_t pred;
	static DataManager *sharedInstance = nil;

	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}

- (NSManagedObjectModel *)objectModel
{
	if (_objectModel)
		return _objectModel;

	NSBundle *bundle = [NSBundle mainBundle];
	if (kDataManagerBundleName) {
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kDataManagerBundleName ofType:@"bundle"];
		bundle = [NSBundle bundleWithPath:bundlePath];
	}
	NSString *modelPath = [bundle pathForResource:kDataManagerModelName ofType:@"momd"];
	_objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];

	return _objectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator)
		return _persistentStoreCoordinator;

	// Get the paths to the SQLite file
	NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kDataManagerSQLiteName];
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];

	// Define the Core Data version migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];

	// Attempt to load the persistent store
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
	}

	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainObjectContext
{
	if (_mainObjectContext)
		return _mainObjectContext;

	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(mainObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _mainObjectContext;
	}

	_mainObjectContext = [[NSManagedObjectContext alloc] init];
	[_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];

	return _mainObjectContext;
}

- (NSString *)sharedDocumentsPath
{
	static NSString *SharedDocumentsPath = nil;
	if (SharedDocumentsPath)
		return SharedDocumentsPath;

	// Compose a path to the <Library>/Database directory
	NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	SharedDocumentsPath = [libraryPath stringByAppendingPathComponent:@"Database"];

	// Ensure the database directory exists
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL isDirectory;
	if (![manager fileExistsAtPath:SharedDocumentsPath isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
		[manager createDirectoryAtPath:SharedDocumentsPath
		   withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
		if (error)
			NSLog(@"Error creating directory path: %@", [error localizedDescription]);
	}

	return SharedDocumentsPath;
}

#pragma mark - functions

NSManagedObjectContext *defaultManagedObjectContext()
{
	return [[DataManager sharedInstance] mainObjectContext];
}

BOOL commitDefaultMOC()
{
	NSManagedObjectContext *moc = defaultManagedObjectContext();

    if ([moc hasChanges]) {

        NSError *error = nil;
        if (![moc save:&error]) {
            // Save failed
            NSLog(@"Core Data Save Error: %@, %@", error, [error userInfo]);
            return NO;
        }
    }
	return YES;
}

void rollbackDefaultMOC()
{
	NSManagedObjectContext *moc = defaultManagedObjectContext();
	[moc rollback];
}

void deleteManagedObjectFromDefaultMOC(NSManagedObject *managedObject)
{
	NSManagedObjectContext *moc = defaultManagedObjectContext();
	[moc deleteObject:managedObject];
}

NSArray *fetchManagedObjects(NSString *entityName, NSPredicate *predicate, NSArray *sortDescriptors, NSManagedObjectContext *moc)
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];

	// Add a sort descriptor. Mandatory.
	[fetchRequest setSortDescriptors:sortDescriptors];
	fetchRequest.predicate = predicate;
    fetchRequest.returnsObjectsAsFaults = NO;

	NSError *error;
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:&error];

	if (fetchResults == nil) {
		// Handle the error.
		NSLog(@"executeFetchRequest failed with error: %@", [error localizedDescription]);
	}

	return fetchResults;
}

NSManagedObject *fetchManagedObject(NSString *entityName, NSPredicate *predicate, NSArray *sortDescriptors, NSManagedObjectContext *moc)
{
	NSArray *fetchResults = fetchManagedObjects(entityName, predicate, sortDescriptors, moc);

	NSManagedObject *managedObject = nil;
    
	if (fetchResults && [fetchResults count] > 0) {
		// Found record
		managedObject = [fetchResults objectAtIndex:0];
	}
    
	return managedObject;
}


@end
