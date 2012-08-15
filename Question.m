//
//  Question.m
//  iRendARAR
//
//  Created by Daniel on 27.07.12.
//
//

#import "Question.h"
#import "Answer.h"

@implementation Question

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
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [@"Frage #" stringByAppendingFormat:@"%i", self.number];
		case 1:
			return @"Antwortmöglichkeiten";
			
		default:
			return @"";
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 1) {
		self.selectedAnswers |= 1 << indexPath.row;
	}
}



@end
