//
//  JTTableViewController.h
//  JTTableViewController
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#define JTTABLEVIEW_heightForRowAtIndexPath \
if(indexPath.row == self.results.count){\
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];\
}

#define JTTABLEVIEW_cellForRowAtIndexPath \
id __nextPageLoaderCell = [super tableView:tableView cellForRowAtIndexPath:indexPath];\
if(__nextPageLoaderCell){\
    return __nextPageLoaderCell;\
}

@interface JTTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

/*!
 * The tableView used by the controller. The delegate and the dataSource are automatically set.
 */
@property (nonatomic) IBOutlet UITableView *tableView;

/*!
 * This view is shown as the last cell of the tableView if haveMoreData is set to YES. The height of the view is set by using the height of the frame, if the height is 0, UITableViewAutomaticDimension will be used.
 */
@property (nonatomic) IBOutlet UITableViewCell *nextPageLoaderCell;

/*!
 * Number of cells require before the last cell for calling startFetchingNextResults. The default value is 3.
 */
@property (nonatomic) NSUInteger nextPageLoaderOffset;

/*!
 * This view is shown when there is no results. The view is automatically added to the superview of the tableView and have the size and position of the tableView. The hidden property is set to YES and userInteractionEnabled to NO.
 */
@property (nonatomic) IBOutlet UIView *noResultsView;

/*!
 * This view is shown when startFetchingResults is called and there is no results. The view is automatically added to the superview of the tableView and have the size and position of the tableView. The hidden property is set to YES and userInteractionEnabled to NO.
 */
@property (nonatomic) IBOutlet UIView *noResultsLoadingView;

/*!
 * Data fetched by startFetchingResults and startFetchingNextResults.
 */
@property (nonatomic, readonly) NSMutableArray *results;

/*!
 * Indicate if there is more data to load. If set to YES display nextPageLoaderCell.
 */
@property (nonatomic, readonly) BOOL haveMoreData;

/*!
 * Indicate when startFetchingResults or startFetchingNextResults are working.
 */
@property (nonatomic, readonly) BOOL isLoading;

/*!
 * Reset results and haveMoreData.
 */
- (void)resetData;

/*!
 * This method is supposed to be call after a successful call to startFetchingResults. If results is empty noResultsView will be shown.
 * @param  results Data store in results.
 * @param  haveMoreData Indicate if there is more data to load.
 */
- (void)didFetchResults:(NSArray *)results haveMoreData:(BOOL)haveMoreData;

/*!
 * This method is supposed to be call after a successful call to startFetchingNextResults.
 * @param  results Data added to results.
 * @param  haveMoreData Indicate if there is more data to load.
 */
- (void)didFetchNextResults:(NSArray *)results haveMoreData:(BOOL)haveMoreData;

/*!
 * This method is supposed to be call after a failed call to startFetchingResults or startFetchingNextResults.
 */
- (void)didFailedToFetchResults;

/*!
 * This method must be call for load new data in results. You must override this method and call super at the beginning.
 * When your data is fetch call didFetchResults:haveMoreData:
 * If you failed to retrieve data call didFailedToFetchResults
 */
- (IBAction)startFetchingResults;

/*!
 * This method must be call for load more data in results. You must override this method and call super at the beginning.
 * When your data is fetch call didFetchNextResults:haveMoreData:
 * If you failed to retrieve data call didFailedToFetchResults
 */
- (IBAction)startFetchingNextResults;

/*!
 *  Show noResultsView, can be overriden if you want some animtaion. By default change the hidden property of noResultsView.
 */
- (void)showNoResultsView;

/*!
 *  Hide noResultsView, can be overriden if you want some animtaion. By default change the hidden property of noResultsView.
 */
- (void)hideNoResultsView;

/*!
 *  Show noResultsLoadingView, can be overriden if you want some animtaion. By default change the hidden property of noResultsLoadingView.
 */
- (void)showNoResultsLoadingView;

/*!
 *  Hide noResultsLoadingView, can be overriden if you want some animtaion. By default change the hidden property of noResultsLoadingView.
 */
- (void)hideNoResultsLoadingView;

/*!
 *  By defaut do nothing, can be overriden if you use a refreshControl. Call when startFetchingResults or startFetchingNextResults are finished.
 */
- (void)endRefreshing;


/*!
 *  Use for Swift, override this method of tableView:heightForRowAtIndexPath:
 */
- (CGFloat)jt_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

/*!
 *  Use for Swift, override this method of tableView:cellForRowAtIndexPath:
 */
- (UITableViewCell *)jt_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;


- (void)commonInit;

@end
