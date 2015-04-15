//
//  FakeService.m
//  Example
//
//  Created by Jonathan Tribouharet
//

#import "FakeService.h"

@interface FakeService ()

@property NSArray *fakeData;

@end

@implementation FakeService

- (instancetype)init
{
    self = [super init];
    if(!self){
        return nil;
    }
    
    [self generateFakeData];
    
    return self;
}

- (void)generateFakeData
{
    self.fakeData = @[@"Dock Gaylord", @"Mr. Izabella Ziemann", @"Haskell Medhurst DDS", @"Rebeka Torp", @"Shannon Kub", @"Kara Donnelly", @"Johnathan Kuphal", @"Jermaine Shanahan", @"Mrs. Rudy Hilll", @"Nathen Kutch Jr.", @"Elissa Lehner", @"Emmanuel Cruickshank", @"Annette Bechtelar", @"Ashleigh Wolff", @"Roberto Crist", @"Rocky Stamm", @"Adolphus Streich MD", @"Andres Rau", @"Ms. Opal Olson", @"Glenda Balistreri", @"Dr. Javon Sipes", @"Devante Leuschke", @"Liliana Bins", @"Mr. Rosie VonRueden", @"Nina Batz", @"Mrs. Garth Rau", @"Jeffrey Bauch", @"Judge Schmitt", @"Raymundo Rau", @"Mr. Kayley Bruen", @"Wava Reilly", @"Ms. Pablo Mosciski", @"Estrella Cremin", @"Bertram Gutmann", @"Raleigh Schuppe", @"Dr. Jace Kuvalis", @"Kelly Terry", @"Mr. Broderick Crooks", @"Tevin Reinger", @"Mckenna Graham V", @"Howard Kuhn", @"Payton Terry", @"Ofelia Osinski", @"Lera Bogan", @"Luz Gutmann DVM", @"Bulah Schaefer", @"Elissa Williamson", @"Joanne Schamberger", @"Orpha Eichmann", @"Haylee Hartmann", @"Cary Toy", @"Danial Marvin", @"Mrs. Wilbert Reynolds", @"Dr. Mable Ledner", @"Albin Leffler", @"Osbaldo Marks", @"Omari Wolf MD", @"Isabelle Schroeder", @"Douglas Kohler", @"Tomasa Reichert", @"Larue Von", @"Taylor Roberts MD", @"Mose Frami", @"Patrick Kautzer I", @"Godfrey Gottlieb V", @"Pearlie Kuhlman MD", @"Dixie Kiehn I", @"Karianne Larson", @"Terry Daugherty Sr.", @"Newell Pfannerstill I", @"Lola Johns", @"Freeda Wintheiser PhD", @"Yolanda Abbott", @"Lauryn Howe", @"June Kautzer", @"Zoie Bradtke", @"Ms. Vanessa Watsica", @"Janae Davis", @"Norene Harris", @"Brooks Ebert Sr."];
}

- (void)retrieveDataWithOffset:(NSUInteger)offset
                       success:(void (^)(NSArray *results, BOOL haveMoreData))success
                       failure:(void (^)())failure
{
    // 2 seconds of delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        BOOL haveMoreData = YES;
        NSUInteger pageSize = 10;
        if((offset + pageSize) >= self.fakeData.count){
            pageSize = self.fakeData.count - offset;
            haveMoreData = NO;
        }
        
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(offset, pageSize)];
        NSArray *dataToReturn = [self.fakeData objectsAtIndexes:indexes];
        
        success(dataToReturn, haveMoreData);
    });
}

- (void)retrieveNoDataWithOffset:(NSUInteger)pageOffset
                         success:(void (^)(NSArray *results, BOOL haveMoreData))success
                         failure:(void (^)())failure
{
    // 2 seconds of delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        success(@[], NO);
    });
}

@end
