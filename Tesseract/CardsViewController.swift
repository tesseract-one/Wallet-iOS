//
//  CardsViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/7/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

struct Card {
  var name: String
  var abbreviation: String
  var balance: Double
  var balanceUpdate: Double
  var icon: UIImage?
  var background: UIImage?
  var accounts: [Account]
}

class CardsViewController: UIViewController {
  
  // MARK: Properties
  //
  @IBOutlet weak var outerView: UIView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var innerView: UIStackView!
  @IBOutlet weak var pageControl: UIPageControl!
  
  var cards = [Card]()
  var cardsViews = [CardView]()
  var cardWidth: CGFloat = 0
  var activeCardIndex: Int = 0 {
    didSet {
      pageControl.currentPage = activeCardIndex
    }
  }
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    cardWidth = outerView.frame.width
    
    loadCards()
    createCardsViews()
    initPageControl()
    scrollCardsToDefaultPosition()
  }
  
  // MARK: Actions
  //
  @IBAction func showPrevCard(_ sender: Any) {
    activeCardIndex = getPrevCardIndex(activeCardIndex)
    scrollToCard(0)
  }
  
  @IBAction func showNextCard(_ sender: Any) {
    activeCardIndex = getNextCardIndex(activeCardIndex)
    scrollToCard(cardWidth * 2)
  }
  
  @IBAction func showRandomCard(_ sender: UIPageControl) {
    let randomCardIndex = sender.currentPage
    
    if randomCardIndex > activeCardIndex {
      if randomCardIndex > activeCardIndex + 1 {
        redrawNextCard(randomCardIndex)
        activeCardIndex = randomCardIndex
        scrollToCard(cardWidth * 2)
      } else {
        showNextCard(sender)
      }
    } else if randomCardIndex < activeCardIndex {
      if randomCardIndex + 1 < activeCardIndex {
        redrawPrevCard(randomCardIndex)
        activeCardIndex = randomCardIndex
        scrollToCard(0)
      } else {
        showPrevCard(sender)
      }
    }
  }
  
  // MARK: Private functions
  //
  private func loadCards() {
    cards = AppState.shared.wallet?.stub.apps.reduce([], { (cards, app) -> [Card] in
      let cardHaveTokenIndex = cards.firstIndex(where: { $0.name == app.token.name })
      
      if cardHaveTokenIndex != nil {
        var cards = cards
        var cardHaveToken = cards[cardHaveTokenIndex!]
        
        cardHaveToken.balance = app.getBalance()
        cardHaveToken.balanceUpdate += app.getBalanceUpdate()
        
        for account in app.accounts {
          let accountLowerBalanceIndex = cardHaveToken.accounts.firstIndex(where: { $0.balance < account.balance })
          
          if (cardHaveToken.accounts.count < 3) {
            if accountLowerBalanceIndex != nil {
              cardHaveToken.accounts.insert(account, at: accountLowerBalanceIndex!)
            } else {
              cardHaveToken.accounts.append(account)
            }
          } else {
            if accountLowerBalanceIndex != nil {
              cardHaveToken.accounts.insert(account, at: accountLowerBalanceIndex!)
              cardHaveToken.accounts.removeLast()
            }
          }
        }
        
        cards[cardHaveTokenIndex!] = cardHaveToken
        return cards
      }
      
      let card = Card.init(
        name: app.token.name,
        abbreviation: app.token.abbreviation,
        balance: app.getBalance(),
        balanceUpdate: app.getBalanceUpdate(),
        icon: app.token.icon,
        background: app.token.background,
        accounts: Array(app.accounts.prefix(3))
      )
      
      return cards + [card]
    }) ?? []
  }
  
  private func createCardsViews() {
    cardsViews = cards.map({ createCardView($0) })
  }
  
  private func createCardView(_ card: Card) -> CardView {
    let cardView = Bundle.loadView(fromNib: "CardView", withType: CardView.self)
    
    cardView.tokenNameLabel.text = card.name
    cardView.backgroundImageView.image = card.background
    cardView.balanceLabel.text = String(Double(card.balance).rounded(toPlaces: 2))
    cardView.balanceUpdateLabel.text = String(Double(card.balanceUpdate).rounded(toPlaces: 2))
    cardView.accountsStackViewHeight.constant = CGFloat(card.accounts.count * 24)

    for account in card.accounts {
      cardView.accountsStackView.addArrangedSubview(createCardAccountView(account))
    }

    return cardView
  }
  
  private func createCardAccountView(_ account: Account) -> CardAccountView {
    let cardAccountView = Bundle.loadView(fromNib: "CardAccountView", withType: CardAccountView.self)
    
    cardAccountView.nameLabel.text = account.name
    cardAccountView.balanceLabel.text = String(Double(account.balance).rounded(toPlaces: 2))
    cardAccountView.iconImageView.image = account.icon
    
    return cardAccountView
  }
  
  private func initPageControl() {
    pageControl.numberOfPages = cardsViews.count
  }
  
  private func scrollCardsToDefaultPosition() {
    redrawCards()
    scrollView.setContentOffset(CGPoint(x: cardWidth, y: 0), animated: false)
  }
  
  private func redrawCards() {
    innerView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    innerView.addArrangedSubview(cardsViews[getPrevCardIndex(activeCardIndex)])
    innerView.addArrangedSubview(cardsViews[activeCardIndex])
    innerView.addArrangedSubview(cardsViews[getNextCardIndex(activeCardIndex)])
    scrollView.layoutSubviews()
  }
  
  public func redrawPrevCard(_ index: Int) {
    innerView.removeArrangedSubview(innerView.arrangedSubviews[0])
    innerView.insertArrangedSubview(cardsViews[index], at: 0)
  }
  
  public func redrawNextCard(_ index: Int) {
    innerView.removeArrangedSubview(innerView.arrangedSubviews[2])
    innerView.insertArrangedSubview(cardsViews[index], at: 2)
  }
  
  private func scrollToCard(_ x: CGFloat) {
    UIView.animate(withDuration: 1.0, animations: {
      self.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
    }, completion: { (finished: Bool) in
      self.scrollCardsToDefaultPosition()
    })
  }

  private func getPrevCardIndex(_ index: Int) -> Int {
    if index >= 1 {
      return index - 1
    } else {
      return cards.count - 1
    }
  }
  
  private func getNextCardIndex(_ index: Int) -> Int {
    if index + 2 <= cards.count {
      return index + 1
    } else {
      return 0
    }
  }
}
