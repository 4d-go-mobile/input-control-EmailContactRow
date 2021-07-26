//
//  EmailContactRow.swift
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___
//  ___COPYRIGHT___
//

import UIKit
import ContactsUI

import Eureka
import QMobileUI

// name of the format
fileprivate let kEmailContact = "emailContact"

// Create an Eureka row for the format
final class EmailContactRow: FieldRow<EmailContactCell>, RowType {

    required public init(tag: String?) {
        super.init(tag: tag)
    }

}

// Create the associated row cell to display a button to pick contact
open class EmailContactCell: EmailCell, CNContactPickerDelegate {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()

        let pickButton = UIButton(primaryAction: UIAction(title: "", image: UIImage(systemName: "person.crop.square.filled.and.at.rectangle") ?? UIImage(systemName: "envelope.circle"), identifier: nil, discoverabilityTitle: "email pick", attributes: [], state: .on, handler: { action in
            self.pickContactProperty(CNContactEmailAddressesKey)
        }))

        self.textField.rightView = pickButton
        self.textField.rightViewMode = .unlessEditing
    }

    fileprivate func pickContactProperty(_ contactProperty: String) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [contactProperty]
        contactPicker.predicateForEnablingContact = NSPredicate(format: "%K.@count > 0", contactProperty) // have property
        contactPicker.predicateForSelectionOfProperty = NSPredicate(format: "key == '\(contactProperty)'") // only selected property
        self.formViewController()?.present(contactPicker, animated: true) {
           // finish
        }
    }

    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        if let email = contactProperty.value as? String {
            self.row.value = email
            self.textField.text = email
        }
    }

    public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        // cancelled
    }
}

@objc(EmailContactRowService)
class EmailContactRowService: NSObject, ApplicationService, ActionParameterCustomFormatRowBuilder {
    @objc static var instance: EmailContactRowService = EmailContactRowService()
    override init() {}
    func buildActionParameterCustomFormatRow(key: String, format: String, onRowEvent eventCallback: @escaping OnRowEventCallback) -> ActionParameterCustomFormatRowType? {
        if format == kEmailContact {
            return EmailContactRow(key).onRowEvent(eventCallback)
        }
        return nil
    }
}
