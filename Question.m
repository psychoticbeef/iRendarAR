//
//  Question.m
//  iRendARAR
//
//  Created by Daniel on 27.07.12.
//
//

#import "Question.h"
#import "Answer.h"
#import "Score.h"

@implementation Question

static Score* score;

- (id)init {
	self = [super init];
	
	static dispatch_once_t once;

	if (self) {
		dispatch_once(&once, ^{
			score = [[Score alloc] init];
		});
	}
	
	return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	switch (section) {
		case 0:
			return 1;
			
		case 1:
			return self.answers.count;
			
		default:
			return 0;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	Answer* a = self.answers[(NSUInteger) indexPath.row];
	
	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	cell.textLabel.numberOfLines = 100;
	
	switch (indexPath.section) {
		case 0:
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = self.questionText;
			break;
			
		case 1:
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = a.answerText;
			
			if ((self.selectedAnswers & (1 << indexPath.row)) > 0 || self.answersExhausted || self.correctlyAnswered) {
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.textColor = ((self.correctAnswerBitmask & (1 << indexPath.row)) > 0) ?
				[UIColor greenColor] : [UIColor redColor];
			}
			
			break;
			
		default:
			cell.textLabel.text = @"";
			break;
	}
	
	if (self.correctlyAnswered || self.answersExhausted) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	NSLog(@"%f", cell.frame.size.height);
	NSLog(@"%@", cell.textLabel.font);
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [NSString stringWithFormat:@"Frage %i von %i", self.number, self.total];

		case 1:
			return @"Antwortmöglichkeiten";
			
		default:
			return @"";
	}
}

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Answer* a = self.answers[(NSUInteger) indexPath.row];
	NSString *text;
	
	switch (indexPath.section) {
		case 0:
			text = self.questionText;
			break;
			
		case 1:
			text = a.answerText;
			break;
			
		default:
			text = @"";
			break;
	}

	// Get a CGSize for the width and, effectively, unlimited height
	CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	// Get the size of the text given the CGSize we just made as a constraint
	
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	// Get the height of our measurement, with a minimum of 44 (standard cell size)
	return MAX(size.height + 2 * CELL_CONTENT_MARGIN, 44.0f);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (self.correctlyAnswered || self.answersExhausted || !self.tableView.userInteractionEnabled)
		return;
	
	if (indexPath.section == 1) {
		if ((self.selectedAnswers | (1 << indexPath.row)) != self.selectedAnswers) {
			Answer* a = self.answers[indexPath.row];
			[score modifyScore:a.points];

			self.selectedAnswers |= (1 << indexPath.row);

			self.tableView.userInteractionEnabled = NO;
			
			NSMutableArray* indexPathes;
			
			NSUInteger completeMask = (1 << self.answers.count) - 1;
			if ((self.selectedAnswers | self.correctAnswerBitmask) == completeMask) {
				self.answersExhausted = YES;
			}
			self.correctlyAnswered = (self.selectedAnswers & self.correctAnswerBitmask) > 0;
			
			if (!self.correctlyAnswered && !self.answersExhausted) {
				indexPathes = [NSMutableArray arrayWithObject:indexPath];
			} else {
				indexPathes = [[NSMutableArray alloc] init];

				for (int i = 0; i < self.answers.count; i++) {
					if (((1 << i) & self.selectedAnswers) == 0) {
						[indexPathes addObject:[NSIndexPath indexPathForRow:i inSection:1]];
					}
				}
				
				[indexPathes addObject:indexPath];
			}
			
			[self.tableView beginUpdates];
			[self.tableView reloadRowsAtIndexPaths:indexPathes withRowAnimation:
			 UITableViewRowAnimationLeft];
			[self.tableView endUpdates];

			
			dispatch_async(dispatch_get_main_queue(), ^{
				//		[self.delegate questionAnswered:self.correctlyAnswered forPoints:a.points];
				[self.delegate questionAnswered:self.correctlyAnswered forPoints:a.points sender:self];
			});
		}
	}
}

@end
