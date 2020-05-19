//
//  CreateMemeViewController.swift
//  MemeMe1.0
//
//  Created by Vanessa on 5/16/20.
//  Copyright © 2020 Vanessa. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    // use to indicate which textField is being active because we only move keyboard for bottom textfield
    var activeField: UITextField?
    var firstTextEdit = (top: false, bottom: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isEnabled = false
        initTextField(topTextField, "TOP")
        initTextField(bottomTextField, "BOTTOM")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeKeyboardNotifications()
    }

    // used for both camera and album
    @IBAction func pickAnImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let button = sender as! UIBarButtonItem
        imagePicker.sourceType = button.tag == 0 ? .camera : .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        let memedImage: UIImage = generateMemedImage()

        // generate the meme
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            if (success) {
                self.save(memedImage)
            }
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func discardMeme(_ sender: Any) {
       shareButton.isEnabled = false
       imagePickerView.image = nil
       topTextField.text = "TOP"
       bottomTextField.text = "BOTTOM"
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // bottom text field
        if textField.tag == 1 {
            activeField = textField
            // only reset if it's first edit or firstTextEdit.bottom = false
            if firstTextEdit.bottom == false {
                textField.text = ""
                firstTextEdit.bottom = true
            }
        }
        else {
            if firstTextEdit.top == false {
                textField.text = ""
                firstTextEdit.top = true
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        if textField.tag == 1 {
            activeField = nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = pickedImage
        }

        dismiss(animated: true, completion: nil)
        shareButton.isEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: keyboard slide
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification:Notification) {
        if self.activeField != nil {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if self.activeField != nil {
            view.frame.origin.y = 0
        }
    }
    
    // MARK: Helpers
    func initTextField(_ textField: UITextField, _ text: String) {
        // foreground color only works if strokeWidth is negative
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -3
        ]
        
        // stop layout auto adjustment warning
        textField.autocorrectionType = .no
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text = text
        textField.delegate = self
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func save(_ memedImage: UIImage) {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        
        // add the meme to the meme array in AppDelegate
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
        
        // Making sure we only dismiss after the file is added
        self.dismiss(animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        toggleToolbar(true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toggleToolbar(false)
        
        return memedImage
    }
    
    func toggleToolbar(_ status: Bool) {
        topToolbar.isHidden = status
        bottomToolbar.isHidden = status
    }
}

