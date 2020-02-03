//
//  WorkoutEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 10/12/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import Introspect

struct WorkoutEditorView : View {
    @State private var amount: Decimal?
    @State private var date: Date?

    public var body: some View {
        ActivityField()
    }
}

struct UserActivity {
    var id = UUID()
    @State var input: String
}

public struct ActivityField: View {
    @State private var newEntry: String = ""
    @State private var activities: [UserActivity] = [
        UserActivity(input: "One"),
        UserActivity(input: "One"),
        UserActivity(input: "One"),
        UserActivity(input: "One"),
        UserActivity(input: "One"),
    ]
    
    public var body: some View {
        var textFieldCtx: UITextField? = nil
        
        return VStack {
            ForEach(activities, id: \.id) { activity in
                TextField("New entry", text: activity.$input, onCommit: {
                    textFieldCtx!.becomeFirstResponder()
                })
            }
            
            TextField("New entry", text: $newEntry, onCommit: {
                print("Now add new entry to activities array")
                self.activities.append(UserActivity(input: self.newEntry))
                self.newEntry = ""
                textFieldCtx!.becomeFirstResponder()
            })
            .introspectTextField { textField in
                textField.becomeFirstResponder()
                textFieldCtx = textField
            }
        }
    }
}

public struct FormattedTextField<Formatter: TextFieldFormatter>: View {
    public init(_ title: String,
                value: Binding<Formatter.Value>,
                formatter: Formatter) {
        self.title = title
        self.value = value
        self.formatter = formatter
    }

    let title: String
    let value: Binding<Formatter.Value>
    let formatter: Formatter
 
    public var body: some View {
        TextField(title, text: Binding(get: {
            if self.isEditing {
                return self.editingValue
            } else {
                return self.formatter.displayString(for: self.value.wrappedValue)
            }
        }, set: { string in
            self.editingValue = string
            self.value.wrappedValue = self.formatter.value(from: string)
        }), onEditingChanged: { isEditing in
            self.isEditing = isEditing
            self.editingValue = self.formatter.editingString(for: self.value.wrappedValue)
        })
    }

    @State private var isEditing: Bool = false
    @State private var editingValue: String = ""
}

public protocol TextFieldFormatter {
    associatedtype Value
    func displayString(for value: Value) -> String
    func editingString(for value: Value) -> String
    func value(from string: String) -> Value
}

struct CurrencyTextFieldFormatter: TextFieldFormatter {
    typealias Value = Decimal?

    func displayString(for value: Decimal?) -> String {
        guard let value = value else { return "" }
        return NumberFormatter.currency.string(for: value) ?? ""
    }

    func editingString(for value: Decimal?) -> String {
        guard let value = value else { return "" }
        return NumberFormatter.currencyEditing.string(for: value) ?? ""
    }

    func value(from string: String) -> Decimal? {
        let formatter = NumberFormatter.currencyEditing
        let value = formatter.number(from: string)?.decimalValue
        let formattedString = value.map { formatter.string(for: $0) } as? String
        return formattedString.map { formatter.number(from: $0)?.decimalValue } as? Decimal
    }
}

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    static let currencyEditing: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        formatter.minimumFractionDigits = NumberFormatter.currency.minimumFractionDigits
        formatter.maximumFractionDigits = NumberFormatter.currency.maximumFractionDigits
        return formatter
    }()
}

struct DateTextFieldFormatter: TextFieldFormatter {
    typealias Value = Date?

    func displayString(for value: Date?) -> String {
        guard let value = value else { return "" }
        return DateFormatter.display.string(from: value)
    }

    func editingString(for value: Date?) -> String {
        guard let value = value else { return "" }
        return DateFormatter.editing.string(from: value)
    }

    func value(from string: String) -> Date? {
        DateFormatter.editing.date(from: string)
    }
}

extension DateFormatter {
    static let display: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()

    static let editing: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#if DEBUG
struct WorkoutEditorView_Previews : PreviewProvider {
    static var previews: some View {
        WorkoutEditorView()
    }
}
#endif
