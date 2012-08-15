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
	
	switch (indexPath.section) {
		case 0:
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = self.questionText;
			break;
			
		case 1:
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = a.answerText;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (self.correctlyAnswered || self.answersExhausted)
		return;
	
	if (indexPath.section == 1) {
		if ((self.selectedAnswers | (1 << indexPath.row)) != self.selectedAnswers) {
			Answer* a = self.answers[indexPath.row];
			[score modifyScore:a.points];

			self.selectedAnswers |= 1 << indexPath.row;
			self.correctlyAnswered = (self.selectedAnswers & self.correctAnswerBitmask) > 0;

			dispatch_async(dispatch_get_main_queue(), ^{
				//		[self.delegate questionAnswered:self.correctlyAnswered forPoints:a.points];
				[self.delegate questionAnswered:self.correctlyAnswered forPoints:a.points];
			});
		}
	}
	
	NSUInteger completeMask = (1 << self.total) - 1;
	if ((self.selectedAnswers | self.correctAnswerBitmask) == completeMask) {
		self.answersExhausted = YES;
		NSLog(@"ANSWERS EXHAUSTED");
	}
}

@end
