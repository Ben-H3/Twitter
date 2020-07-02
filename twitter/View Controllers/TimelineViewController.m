//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "ComposeViewController.h"
#import "DetailsViewController.h"
#import "APIManager.h"
#import "TweetCell.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface TimelineViewController () <ComposeViewControllerDelegate, TweetDetailViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Set up refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    
    // Set up tweet array
    self.tweets = [[NSMutableArray alloc] init];
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            self.tweets = tweets;
            [self.tableView reloadData];
            
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}

-(void) beginRefresh: (UIRefreshControl *) refreshControl {
    // Reload tweets when refresh
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            self.tweets = tweets;
            [self.tableView reloadData];
            
            [refreshControl endRefreshing];
            
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
    
}


- (IBAction)logout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    [[APIManager shared] logout];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    Tweet *tweet = self.tweets[indexPath.row];
    cell.tweet = tweet;
    [cell loadTweet];
    return cell;
}

-(void)didTweet:(Tweet *)tweet{
    [self.tweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

- (void) updateCell:(TweetCell *)cell{
    [cell loadTweet];
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[DetailsViewController class]]) {
        TweetCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.tweet = self.tweets[indexPath.row];
        detailsViewController.cell = tappedCell;
        detailsViewController.delegate = self;
    }
    else {
        UINavigationController *navController = [segue destinationViewController];
        ComposeViewController *composeViewController = (ComposeViewController*)navController.topViewController;
        composeViewController.delegate = self;
        if ([segue.identifier isEqualToString:@"reply"]) {
            composeViewController.reply = YES;
            for (Tweet* tweet in self.tweets) {
                if (tweet.replyClicked == YES) {
                    composeViewController.tweet = tweet;
                }
            }
        }
        else {
            composeViewController.reply = NO;
        }
    }
}

@end
