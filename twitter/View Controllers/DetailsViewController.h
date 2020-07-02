//
//  DetailsViewController.h
//  twitter
//
//  Created by Benjamin Charles Hora on 6/30/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "TweetCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TweetDetailViewControllerDelegate

- (void) didTweet:(Tweet *)tweet;
- (void) updateCell:(TweetCell *)cell;

@end

@interface DetailsViewController : UIViewController

@property (strong, nonatomic) Tweet *tweet;
@property (strong, nonatomic) TweetCell *cell;

@property (weak, nonatomic) id<TweetDetailViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
