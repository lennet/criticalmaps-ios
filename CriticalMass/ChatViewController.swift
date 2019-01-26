//
//  ChatViewController.swift
//  CriticalMaps
//
//  Created by Leonard Thomas on 1/25/19.
//

import UIKit

class ChatViewController: UIViewController, ChatInputDelegate {
    let chatInput = ChatInputView(frame: .zero)
    let messagesTableViewController = MessagesTableViewController<ChatMessageTableViewCell>(style: .plain)
    let chatManager: ChatManager

    @objc init(chatManager: ChatManager) {
        self.chatManager = chatManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureChatInput()
        configureMessagesTableViewController()
    }

    private func configureNavigationBar() {
        title = NSLocalizedString("chat.title", comment: "")
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    private func configureMessagesTableViewController() {
        messagesTableViewController.register(cellType: ChatMessageTableViewCell.self)
        messagesTableViewController.noContentMessage = NSLocalizedString("chat.noChatActivity", comment: "")
        messagesTableViewController.messages = chatManager.getMessages()

        let tapGestureRecoognizer = UITapGestureRecognizer(target: self, action: #selector(didTapTableView))
        messagesTableViewController.view.addGestureRecognizer(tapGestureRecoognizer)
        chatManager.updateMessagesCallback = { [weak self] messages in
            self?.messagesTableViewController.update(messages: messages)
        }

        addChild(messagesTableViewController)
        view.addSubview(messagesTableViewController.view)
        messagesTableViewController.didMove(toParent: self)
        messagesTableViewController.view.translatesAutoresizingMaskIntoConstraints = false

        view.addConstraints([
            NSLayoutConstraint(item: messagesTableViewController.view, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: messagesTableViewController.view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: messagesTableViewController.view, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: messagesTableViewController.view, attribute: .bottom, relatedBy: .equal, toItem: chatInput, attribute: .top, multiplier: 1, constant: 0),
        ])
    }

    private func configureChatInput() {
        chatInput.delegate = self
        view.addSubview(chatInput)

        view.addConstraints([
            NSLayoutConstraint(item: chatInput, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 64),
            NSLayoutConstraint(item: chatInput, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: chatInput, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: chatInput, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0),
        ])
    }

    @objc private func didTapTableView() {
        chatInput.resignFirstResponder()
    }

    // MARK: ChatInputDelegate

    func didTapSendButton(text: String) {
        // TODO: show loading indicator
        // TODO: fix bug
        chatManager.send(message: text) { success in
            if success {
                self.chatInput.resetInput()
            } else {
                // TODO: present error
            }
        }
    }
}