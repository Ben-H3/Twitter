//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "ComposeViewController.h"
#import "APIManager.h"
#import "TweetCell.h"

@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

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

-(void)didTweet:(Tweet *)tweet{
    [self.tweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationController = [segue destinationViewController];
    ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
    composeController.delegate = self;
}

@end
