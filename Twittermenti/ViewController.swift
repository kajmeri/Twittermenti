//
//  ViewController.swift
//  Twittermenti
//
//  Created by Krishna Ajmeri on 9/13/19.
//  Copyright © 2019 Krishna Ajmeri. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {

	@IBOutlet weak var sentimentLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	
	let keys = Keys()
	
	let sentimentClassifier = TweetSentimentClassifier()

	let tweetCount = 100

	override func viewDidLoad() {
		super.viewDidLoad()
		
		print(keys.apiKey)
		
	}

	@IBAction func predictPressed(_ sender: UIButton) {

		fetchTweets()

	}

	func fetchTweets() {
		if let searchText = textField.text {
			let swifter = Swifter(consumerKey: keys.apiKey, consumerSecret: keys.apiSecret)

			swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in

				var tweets = [TweetSentimentClassifierInput]()

				for i in 0..<100 {
					if let tweet = results[i]["full_text"].string {
						let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
						tweets.append(tweetForClassification)
					}
				}

				self.makePrediction(with: tweets)

			}) { (error) in
				print("Error fetching tweets, \(error)")
			}

		}

	}

	func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
		do {
			let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
			var score = 0
			for prediction in predictions {

				if prediction.label == "Pos" {
					score += 1
				} else if prediction.label == "Neg" {
					score -= 1
				}
			}

			updateUI(with: score)

		} catch {
			print("Unable to predict, \(error)")
		}

	}

	func updateUI(with score: Int) {

		if score > 20 {
			self.sentimentLabel.text = "😍"
		} else if score > 10 {
			self.sentimentLabel.text = "😀"
		} else if score > 0 {
			self.sentimentLabel.text = "🙂"
		} else if score == 0 {
			self.sentimentLabel.text = "😐"
		} else if score > -10 {
			self.sentimentLabel.text = "😕"
		} else if score > -20 {
			self.sentimentLabel.text = "😡"
		} else {
			self.sentimentLabel.text = "🤮"
		}

	}
	
}

