//
//  FakeService.h
//  Example
//
//  Created by Jonathan Tribouharet
//

#import <Foundation/Foundation.h>

@interface FakeService : NSObject

// Simulate a call to an API, use just for the example, nothing can be done with this
- (void)retrieveDataWithOffset:(NSUInteger)pageOffset
                       success:(void (^)(NSArray *results, BOOL haveMoreData))success
                       failure:(void (^)())failure;


// Use this method to test the noResultsView
- (void)retrieveNoDataWithOffset:(NSUInteger)pageOffset
                         success:(void (^)(NSArray *results, BOOL haveMoreData))success
                         failure:(void (^)())failure;

@end
