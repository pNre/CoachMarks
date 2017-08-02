//
//  ViewController.swift
//  CoachMarkExample
//
//  Created by Pierluigi D'Andrea on 26/02/17.
//  Copyright © 2017 pNre. All rights reserved.
//

import CoachMarks
import UIKit

class ViewController: UIViewController {

    private lazy var coachmark: CoachmarkView = CoachmarkView()

    override func viewDidLoad() {

        super.viewDidLoad()

        coachmark.delegate = self

        view.addSubview(coachmark)

        coachmark.translatesAutoresizingMaskIntoConstraints = false
        coachmark.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        coachmark.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        coachmark.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        coachmark.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        coachmark.textLabel.textColor = .white
        coachmark.textLabel.text = "👋 this is a little example app showcasing some coach marks"

        coachmark.present(in: view, from: CGRect(x: view.bounds.width, y: view.bounds.height, width: 0, height: 0), focusingOnElement: false)

    }

    // MARK: - Actions
    @IBAction func lemonButtonPressedAction(_ button: UIButton) {

        coachmark.tintColor = .yellow

        coachmark.textLabel.textColor = .black
        coachmark.textLabel.text = "The distinctive sour taste of lemon juice makes it a key ingredient in drinks and foods such as lemonade and lemon meringue pie."

        coachmark.present(in: view, from: button.frame, focusingOnElement: true)

    }

    @IBAction func cookieButtonPressedAction(_ button: UIButton) {

        coachmark.tintColor = UIColor(red: 0.57, green: 0.21, blue: 0.06, alpha: 1.0)

        coachmark.textLabel.textColor = .white
        coachmark.textLabel.text = "A cookie is a baked or cooked good that is small, flat, and sweet, usually containing flour, sugar and some type of oil or fat. It may include other ingredients such as raisins, oats, chocolate chips or nuts."

        coachmark.present(in: view, from: button.frame, focusingOnElement: false)

    }

    @IBAction func pineappleButtonPressedAction(_ button: UIButton) {

        coachmark.tintColor = UIColor(red: 0.0, green: 0.7, blue: 0.4, alpha: 1.0)

        coachmark.textLabel.textColor = .white
        coachmark.textLabel.text = "The pineapple (Ananas comosus) is a tropical plant with an edible multiple fruit consisting of coalesced berries."

        coachmark.present(in: view, from: button.frame, focusingOnElement: true)

    }

}

// MARK: - 
extension ViewController: CoachmarkViewDelegate {

    func coachmarkViewDidComplete(_ view: CoachmarkView) {

        print("Coachmark did complete")

    }

}
