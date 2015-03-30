#import <UIKit/UIKit.h>

@interface MainViewController: UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *optionsTable;

@end
