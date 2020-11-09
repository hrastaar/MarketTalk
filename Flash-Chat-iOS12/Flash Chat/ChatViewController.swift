
import UIKit
import Firebase
import ChameleonFramework

// Control the VC, Table being used, Data at the table, and the text field
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArr : [Message] = [Message]()
    var teamInfo: TeamData?
    let db = Firestore.firestore()
    // Control height constraints of messenger section
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageActionsView: UIView!
    var username: String?
    var preferredClub: String? 

    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.dataSource = self
        messageTextfield.delegate = self
        messageTextfield.backgroundColor = .white
        if let teamColors = teamColors[self.teamInfo!.team] {
            messageActionsView.backgroundColor = UIColor(hexString: teamColors[0])
            messageTableView.separatorColor = UIColor(hexString: teamColors[0])

        }
        // lets you know when tapped
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier:  "ReusableCell")
        retrieveMessages()
    }
    
    //MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MessageCell
        // User settings default
        cell.messageBody.text = messageArr[indexPath.row].message
        cell.senderUsername.text = messageArr[indexPath.row].sender
        let imageString = "AssetBundle.bundle/" + messageArr[indexPath.row].club + ".png"
        cell.avatarImageView.image = UIImage(named: imageString)
        // if looking at own message from own phone
        if let currUser = username {
            if(cell.senderUsername.text == currUser){
                // Own message showing
                cell.avatarImageView.backgroundColor = UIColor.flatGray()
                cell.messageBackground.backgroundColor = UIColor.flatMint()
            }
            // if viewing other person's message
            else{
                cell.avatarImageView.backgroundColor = UIColor.flatBlue()
                cell.messageBackground.backgroundColor = UIColor.flatGray()
            }
        } else {
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
    @IBAction func sendPressed(_ sender: Any) {
        if(self.username == nil) {
            print("User was nil, so can't post")
            return
        }
        // Sending messages to Firebase DB
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        if let messageBody = messageTextfield.text, let messageSender = self.username, let messageClub = self.preferredClub {
            db.collection(self.teamInfo!.team).addDocument(data: [
                "sender" : messageSender,
                "body" : messageBody,
                "club" : messageClub,
                "dateField" : Date().timeIntervalSince1970
            ]) { (error) in
                if error != nil {
                    print("Issue occurred when saving data to firestore")
                } else {
                    print("Successfully saved data")
                    
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
    }

    // this function retreieves messages to showcase
    func retrieveMessages() {
        db.collection(self.teamInfo!.team)
            .order(by: "dateField")
            .addSnapshotListener { (querySnapshot, error) in
            
            self.messageArr = []
            
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data["sender"] as? String, let messageBody = data["body"] as? String, let messageClub = data["club"] as? String {
                            let newMessage = Message()
                            newMessage.message = messageBody
                            newMessage.sender = messageSender
                            newMessage.club = messageClub
                            self.messageArr.append(newMessage)
                            
                            DispatchQueue.main.async {
                                   self.messageTableView.reloadData()
                                let indexPath = IndexPath(row: self.messageArr.count - 1, section: 0)
                                self.messageTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }

}
