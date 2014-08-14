// DataManager.h
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject {
}

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DataManager *)sharedInstance;

NSManagedObjectContext *defaultManagedObjectContext();
BOOL commitDefaultMOC();
void rollbackDefaultMOC();
void deleteManagedObjectFromDefaultMOC(NSManagedObject *managedObject);
NSArray *fetchManagedObjects(NSString *entityName, NSPredicate *predicate, NSArray *sortDescriptors, NSManagedObjectContext *moc);
NSManagedObject *fetchManagedObject(NSString *entityName, NSPredicate *predicate, NSArray *sortDescriptors, NSManagedObjectContext *moc);

@end
