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

enum CardPos {
  case center
  case right
  case left
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
    scrollCard(.left)
  }
  
  @IBAction func showNextCard(_ sender: Any) {
    activeCardIndex = getNextCardIndex(activeCardIndex)
    scrollCard(.right)
  }
  
  @IBAction func showChoosenCard(_ sender: UIPageControl) {
    let choosenCardIndex = sender.currentPage
    
    if choosenCardIndex > activeCardIndex {
      if choosenCardIndex > activeCardIndex + 1 {
        redrawNextCard(choosenCardIndex)
        activeCardIndex = choosenCardIndex
        scrollCard(.right)
      } else {
        showNextCard(sender)
      }
    } else if choosenCardIndex < activeCardIndex {
      if choosenCardIndex + 1 < activeCardIndex {
        redrawPrevCard(choosenCardIndex)
        activeCardIndex = choosenCardIndex
        scrollCard(.left)
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
    
    var leftCard = cardsViews[getPrevCardIndex(activeCardIndex)]
    let centralCard = cardsViews[activeCardIndex]
    var rightCard = cardsViews[getNextCardIndex(activeCardIndex)]
    
    innerView.addArrangedSubview(leftCard)
    innerView.addArrangedSubview(centralCard)
    innerView.addArrangedSubview(rightCard)
    
    leftCard = transformToSidecard(.left, leftCard)
    rightCard = transformToSidecard(.right, rightCard)
    
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
  
  private func scrollCard(_ cardPos: CardPos) {
    UIView.animate(withDuration: 1.0, animations: {
      if cardPos == CardPos.left {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        let leftCard = self.innerView.arrangedSubviews[0]
        leftCard.transform = .identity
        leftCard.alpha = 1
        
        var centralCard = self.innerView.arrangedSubviews[1] as! CardView
        centralCard = self.transformToSidecard(.right, centralCard)
      } else if cardPos == CardPos.right {
        self.scrollView.setContentOffset(CGPoint(x: self.cardWidth * 2, y: 0), animated: false)
        
        let rightCard = self.innerView.arrangedSubviews[2]
        rightCard.transform = .identity
        rightCard.alpha = 1
        
        var centralCard = self.innerView.arrangedSubviews[1] as! CardView
        centralCard = self.transformToSidecard(.left, centralCard)
      }
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
  
  private func transformToSidecard(_ pos: CardPos, _ card: CardView) -> CardView {
    // we can't transform cards until we calculate their height
    let scale = (card.frame.height - 32)/card.frame.height
    let scaledCardDifferenceX = (1 - scale) * card.frame.width / 2
    let transformX = (24 / scale + scaledCardDifferenceX) // transform will be scaled?
    
    var cardTransform = CGAffineTransform.identity
    cardTransform = cardTransform.scaledBy(x: scale, y: scale)
    cardTransform = cardTransform.translatedBy(x: pos == .left ? transformX : -transformX, y: 0)
    card.transform = cardTransform
    card.alpha = 0.5
    
    return card
  }
}
