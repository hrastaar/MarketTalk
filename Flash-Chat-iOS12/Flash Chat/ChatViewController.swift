
import UIKit
import Firebase
import ChameleonFramework

// Control the VC, Table being used, Data at the table, and the text field
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArr : [Message] = [Message]()
    
    // Control height constraints of messenger section
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    // For the send button
    @IBOutlet var sendButton: UIButton!
    // Message storage
    @IBOutlet var messageTextfield: UITextField!
    // Table
    @IBOutlet var messageTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextfield.delegate = self
        
        // lets you know when tapped
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }
    
    //MARK: - TableView DataSource Methods
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        // User settings default
        cell.messageBody.text = messageArr[indexPath.row].message
        cell.senderUsername.text = messageArr[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "bull")
        // if looking at own message from own phone
        if(cell.senderUsername.text == Auth.auth().currentUser?.email!){
            // Own message showing
            cell.avatarImageView.backgroundColor = UIColor.flatGray()
            cell.messageBackground.backgroundColor = UIColor.flatMint()
        }
        // if viewing other person's message
        else{
            cell.avatarImageView.backgroundColor = UIColor.flatBlue()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        return cell
    }
    
    
    // Simple function to return number of messages
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArr.count
    }
    
    // Use this call to escape keyboard
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    // simple tableview settings
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
    //MARK:- TextField Delegate Methods
    
    

    
    // Move keyboard when you want to type
    func textFieldDidBeginEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.4){
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
            
        }
    }
    
    // remove keyboard when done with typing AKA clicking somewhere else
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.4){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {

        // Sending messages to Firebase DB
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        // enter specific child of Messages
        let messagesDB = Database.database().reference().child("Messages")
        // create a constant to hold sender and message text
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text!]
        // creates random key for messages so they are all unique
        messagesDB.childByAutoId().setValue(messageDictionary)
        {
           (error, reference) in
            if error != nil
            {
                print(error!)
            }
            else{
                print("Message saved successfully!")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }// creates random key for messages so they are all unique
        
    }
    
    // this function retreieves messages to showcase
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        // whenever a new entry added to messages DB
        messageDB.observe(.childAdded) { (snapshot) in
            let value_of_snapshot = snapshot.value as! Dictionary<String,String>
            
            let textConst = value_of_snapshot["MessageBody"]!
            let sender = value_of_snapshot["Sender"]!
            let fullMessageInfo = Message()
            fullMessageInfo.sender = sender
            fullMessageInfo.message = textConst
            
            self.messageArr.append(fullMessageInfo)
            
            self.configureTableView()
            self.messageTableView.reloadData()
    }
    

    }
    
    // IBAction for when user presses the log-out button
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("Error, problem signing out")
        }
    }
    


}
