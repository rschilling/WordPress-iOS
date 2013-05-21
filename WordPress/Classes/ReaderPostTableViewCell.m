//
//  ReaderPostTableViewCell.m
//  WordPress
//
//  Created by Eric J on 4/4/13.
//  Copyright (c) 2013 WordPress. All rights reserved.
//

#import "ReaderPostTableViewCell.h"
#import <DTCoreText/DTCoreText.h>
#import "UIImageView+Gravatar.h"
#import "WordPressAppDelegate.h"
#import "WPWebViewController.h"

#define RPTVCVerticalPadding 10.0f;

@interface ReaderPostTableViewCell() <DTAttributedTextContentViewDelegate>

@property (nonatomic, strong) ReaderPost *post;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *byView;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *reblogButton;
@property (nonatomic, strong) UILabel *bylineLabel;
@property (nonatomic, assign) BOOL showImage;

- (CGFloat)requiredRowHeightForWidth:(CGFloat)width tableStyle:(UITableViewStyle)style;
- (void)handleLikeButtonTapped:(id)sender;
- (void)handleFollowButtonTapped:(id)sender;
- (void)handleReblogButtonTapped:(id)sender;

@end

@implementation ReaderPostTableViewCell

+ (NSArray *)cellHeightsForPosts:(NSArray *)posts
						   width:(CGFloat)width
					  tableStyle:(UITableViewStyle)tableStyle
					   cellStyle:(UITableViewCellStyle)cellStyle
				 reuseIdentifier:(NSString *)reuseIdentifier {

	NSMutableArray *heights = [NSMutableArray arrayWithCapacity:[posts count]];
	ReaderPostTableViewCell *cell = [[ReaderPostTableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:reuseIdentifier];
	for (ReaderPost *post in posts) {
		[cell configureCell:post];
		CGFloat height = [cell requiredRowHeightForWidth:width tableStyle:tableStyle];
		[heights addObject:[NSNumber numberWithFloat:height]];
	}
	return heights;
}


#pragma mark - Lifecycle Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		
		self.contentView.backgroundColor = [UIColor colorWithHexString:@"F1F1F1"];
		CGRect frame = CGRectMake(10.0f, 0.0f, self.contentView.frame.size.width - 20.0f, self.contentView.frame.size.height - 10.0f);
		CGFloat width = frame.size.width;

		self.containerView = [[UIView alloc] initWithFrame:frame];
		_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_containerView.backgroundColor = [UIColor whiteColor];
		[self.contentView addSubview:_containerView];
		
		self.imageView.contentMode = UIViewContentModeScaleAspectFill;
		[_containerView addSubview:self.imageView];

		self.textContentView.frame = CGRectMake(0.0f, 0.0f, width, 44.0f);
		[_containerView addSubview:self.textContentView];
				
		self.byView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, (width - 20.0f), 32.0f)];
		_byView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_containerView addSubview:_byView];
		
		self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
		[_byView addSubview:_avatarImageView];
		
		self.bylineLabel = [[UILabel alloc] initWithFrame:CGRectMake(37.0f, 0.0f, width - 57.0f, 32.0f)];
		_bylineLabel.numberOfLines = 2;
		_bylineLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_bylineLabel.font = [UIFont systemFontOfSize:14.0f];
		_bylineLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
		_bylineLabel.backgroundColor = [UIColor clearColor];
		[_byView addSubview:_bylineLabel];
		
		
		UIColor *color = [UIColor colorWithHexString:@"3478E3"];
		CGFloat fontSize = 16.0f;
		self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_followButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
		[_followButton setTitle:NSLocalizedString(@"Follow", @"") forState:UIControlStateNormal];
		[_followButton setTitleColor:color forState:UIControlStateNormal];
		[_followButton setImage:[UIImage imageNamed:@"note_icon_follow"] forState:UIControlStateNormal];
		_followButton.frame = CGRectMake(0.0f, 0.0f, 100.0f, 40.0f);
		[_followButton addTarget:self action:@selector(handleFollowButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

		self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_likeButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
		[_likeButton setTitle:NSLocalizedString(@"Like", @"") forState:UIControlStateNormal];
		[_likeButton setTitleColor:color forState:UIControlStateNormal];
		[_likeButton setImage:[UIImage imageNamed:@"note_icon_like"] forState:UIControlStateNormal];
		_likeButton.frame = CGRectMake(100.0f, 0.0f, 100.0f, 40.0f);
		_likeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[_likeButton addTarget:self action:@selector(handleLikeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		self.reblogButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_reblogButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
		[_reblogButton setTitle:NSLocalizedString(@"Reblog", @"") forState:UIControlStateNormal];
		[_reblogButton setTitleColor:color forState:UIControlStateNormal];
		[_reblogButton setImage:[UIImage imageNamed:@"note_icon_reblog"] forState:UIControlStateNormal];
		_reblogButton.frame = CGRectMake(200.0f, 0.0f, 100.0f, 40.0f);
		_reblogButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[_reblogButton addTarget:self action:@selector(handleReblogButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		self.controlView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 40.0f)];
		_controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		[_controlView addSubview:_followButton];
		[_controlView addSubview:_likeButton];
		[_controlView addSubview:_reblogButton];
		[_containerView addSubview:_controlView];
		
    }
	
    return self;
}


- (void)layoutSubviews {
	[super layoutSubviews];

	CGFloat contentWidth = _containerView.frame.size.width;
	CGFloat nextY = 0.0f;
	CGFloat vpadding = RPTVCVerticalPadding;
	CGFloat height = 0.0f;

	// Are we showing an image? What size should it be?
	if(_showImage) {
		height = (contentWidth * 0.66f);
		self.imageView.frame = CGRectMake(0.0f, nextY, contentWidth, height);
		nextY += ceilf(height + vpadding);
	} else {
		nextY += vpadding;
	}

	// Position the snippet
	height = [self.textContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth].height;
	self.textContentView.frame = CGRectMake(0.0f, nextY, contentWidth, height);
	[self.textContentView layoutSubviews];
	nextY += ceilf(height + vpadding);

	// position the byView
	height = _byView.frame.size.height;
	CGFloat width = contentWidth - 20.0f;
	_byView.frame = CGRectMake(10.0f, nextY, width, height);
	nextY += ceilf(height + vpadding);
	
	// position the control bar
	height = _controlView.frame.size.height;
	_controlView.frame = CGRectMake(0.0f, nextY, contentWidth, height);
}


- (void)prepareForReuse {
	[super prepareForReuse];
	
	_avatarImageView.image = nil;
	_bylineLabel.text = nil;
}


#pragma mark - Instance Methods

- (CGFloat)requiredRowHeightForWidth:(CGFloat)width tableStyle:(UITableViewStyle)style {
	
	CGFloat desiredHeight = 0.0f;
	CGFloat vpadding = RPTVCVerticalPadding;
	
	// Do the math. We can't trust the cell's contentView's frame because
	// its not updated at a useful time during rotation.
	CGFloat contentWidth = width - 20.0f; // 10px padding on either side.
	
	// reduce width for accessories
	switch (self.accessoryType) {
		case UITableViewCellAccessoryDisclosureIndicator:
		case UITableViewCellAccessoryCheckmark:
			contentWidth -= 20.0f;
			break;
		case UITableViewCellAccessoryDetailDisclosureButton:
			contentWidth -= 33.0f;
			break;
		case UITableViewCellAccessoryNone:
			break;
	}
	
	// reduce width for grouped table views
	if (style == UITableViewStyleGrouped) {
		contentWidth -= 19;
	}
	
	// Are we showing an image? What size should it be?
	if(_showImage) {
		CGFloat height = (contentWidth * 0.66f);
		desiredHeight += height;
	}
	
	desiredHeight += vpadding;
	
	// Size of the snippet
	desiredHeight += [self.textContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth].height;
	desiredHeight += vpadding;
	
	// Size of the byview
	desiredHeight += (_byView.frame.size.height + vpadding);
	
	// size of the control bar
	desiredHeight += (_controlView.frame.size.height + vpadding);
	
	desiredHeight += vpadding;
	
	return desiredHeight;
}


- (void)configureCell:(ReaderPost *)post {
	self.post = post;
	NSString *str;
	NSString *contentSnippet = post.summary;
	if(contentSnippet && [contentSnippet length] > 0){
		str = [NSString stringWithFormat:@"<h3 style=\"color:#000000;font-size:18px;font-weight:100;margin-bottom:8px;\">%@</h3>%@", post.postTitle, contentSnippet];
	} else {
		str = [NSString stringWithFormat:@"<h3 style=\"color:#000000;font-size:18px;font-weight:100;margin-bottom:8px;\">%@</h3>", post.postTitle];
	}

	self.textContentView.attributedString = [self convertHTMLToAttributedString:str withOptions:nil];

	
	_bylineLabel.text = [NSString stringWithFormat:@"%@ \non %@", [post prettyDateString], post.blogName];

	self.showImage = NO;
	self.imageView.hidden = YES;
	NSURL *url = nil;
	if (post.featuredImage) {
		self.showImage = YES;
		self.imageView.hidden = NO;

		NSInteger width = ceil(_containerView.frame.size.width);
		NSString *path = [NSString stringWithFormat:@"https://i0.wp.com/%@?w=%i", post.featuredImage, width];
		url = [NSURL URLWithString:path];

		[self.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"gravatar.jpg"]];
	}
	
	NSString *likeStr = NSLocalizedString(@"Like", @"Like button title.");
	if ([self.post.likeCount integerValue] > 0) {
		likeStr = [NSString stringWithFormat:@"%@ (%@)", likeStr, [self.post.likeCount stringValue]];
	}
	[_likeButton setTitle:likeStr forState:UIControlStateNormal];
	
	[self.avatarImageView setImageWithBlavatarUrl:[[NSURL URLWithString:post.blogURL] host]];
	
	[self updateControlBar];
}


- (void)updateControlBar {
	if (!_post) return;
	
	UIColor *activeColor = [UIColor colorWithHexString:@"F1831E"];
	UIColor *inactiveColor = [UIColor colorWithHexString:@"3478E3"];;
	
	UIImage *img = nil;
	UIColor *color;
	if (_post.isLiked.boolValue) {
		img = [UIImage imageNamed:@"note_navbar_icon_like"];
		color = activeColor;
	} else {
		img = [UIImage imageNamed:@"note_icon_like"];
		color = inactiveColor;
	}
	[_likeButton.imageView setImage:img];
	[_likeButton setTitleColor:color forState:UIControlStateNormal];
	
	if (_post.isReblogged.boolValue) {
		img = [UIImage imageNamed:@"note_navbar_icon_reblog"];
		color = activeColor;
	} else {
		img = [UIImage imageNamed:@"note_icon_reblog"];
		color = inactiveColor;
	}
	[_reblogButton.imageView setImage:img];
	[_reblogButton setTitleColor:color forState:UIControlStateNormal];
	
	if (_post.isFollowing.boolValue) {
		img = [UIImage imageNamed:@"note_navbar_icon_follow"];
		color = activeColor;
	} else {
		img = [UIImage imageNamed:@"note_icon_follow"];
		color = inactiveColor;
	}
	[_followButton.imageView setImage:img];
	[_followButton setTitleColor:color forState:UIControlStateNormal];
}


- (void)handleLikeButtonTapped:(id)sender {
	NSLog(@"Tapped like");
	[self.post toggleLikedWithSuccess:^{
		// Nothing to see here?
	} failure:^(NSError *error) {
		[self updateControlBar];
	}];
	
	[self updateControlBar];
}


- (void)handleFollowButtonTapped:(id)sender {
	NSLog(@"Tapped follow");
	[self.post toggleFollowingWithSuccess:^{
		
	} failure:^(NSError *error) {
		[self updateControlBar];
	}];
	
	[self updateControlBar];
}


- (void)handleReblogButtonTapped:(id)sender {
	NSLog(@"Tapped reblog");
	[self.post reblogPostToSite:nil success:^{
		
	} failure:^(NSError *error) {
		[self updateControlBar];
	}];
	
	[self updateControlBar];
}


@end