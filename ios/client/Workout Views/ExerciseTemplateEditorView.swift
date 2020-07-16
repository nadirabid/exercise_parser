//
//  ExerciseTemplateEditorView.swift
//  client
//
//  Created by Nadir Muzaffar on 7/16/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct ExerciseTemplateEditorView: View {
    var exerciseTemplate: ExerciseTemplate
    var viewWidth: CGFloat
    
    @ObservedObject private var dataFields: ExerciseTemplateDataFields
    @State private var activeFields: [ExerciseField] = []
    
    init(exerciseTemplate: ExerciseTemplate, viewWidth: CGFloat) {
        self.exerciseTemplate = exerciseTemplate
        self.viewWidth = viewWidth
        
        self.dataFields = self.exerciseTemplate.data
    }
    
    func calculateWidthFor(field: ExerciseField) -> CGFloat {
        return viewWidth / CGFloat(activeFields.count)
    }
    
    func createColumnTitleViewFor(field: ExerciseField) -> some View {
        HStack {
            if activeFields.last == field {
                Spacer()
            }
            
            if activeFields.first == field {
                Text(field.description.uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.secondary)
                    .frame(width: calculateWidthFor(field: field), alignment: .leading)
            } else if field != activeFields.last {
                Text(field.description.uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.secondary)
                    .frame(width: calculateWidthFor(field: field), alignment: .trailing)
            } else {
                Text(field.description.uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.secondary)
            }
        }
    }
    
    func createColumnViewFor(field: ExerciseField, _ itemSetIndex: Int) -> some View {
        HStack(alignment: .center) {
            if field == activeFields.last {
                Spacer()
            }
            
            if field == .sets {
                Text("\(itemSetIndex + 1)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(4)
                    .frame(width: 30)
                    .fixedSize()
                    .background(Circle().fill(Color(UIColor.systemGray6)))
                    .frame(width: calculateWidthFor(field: field), alignment: .leading)
            } else {
                createTextFieldFor(field: field, itemSetIndex: itemSetIndex)
                    .font(self.infoFont)
                    .keyboardType(.numberPad)
            }
        }
        .multilineTextAlignment(.trailing)
        //.padding(.bottom, itemSetIndex == dataFields.defaultValueSets - 1 ? 0 : 5)
        .frame(width: field == activeFields.last ? nil : calculateWidthFor(field: field))
    }
    
    func createTextFieldFor(field: ExerciseField, itemSetIndex: Int) -> some View {
        if field == .reps {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.repsValues[itemSetIndex])"
                },
                set: { (value) in
                    self.dataFields.repsValues = self.dataFields.repsValues.map { $0 }
                    
                    if let v = Int(value) {
                        self.dataFields.repsValues[itemSetIndex] = v
                    }
                }
            )
            
            return TextField("0", text: b)
        } else if field == .weight {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.weightValues[itemSetIndex].format(f: ".0"))"
                },
                set: { (value) in
                    self.dataFields.weightValues = self.dataFields.weightValues.map { $0 }
                    
                    if let v = Float(value) {
                        self.dataFields.weightValues[itemSetIndex] = v
                    }
                }
            )
            
            return TextField("0", text: b)
        } else if field == .distance {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.distanceValues[itemSetIndex].format(f: ".0"))"
                },
                set: { (value) in
                    self.dataFields.distanceValues = self.dataFields.distanceValues.map { $0 }
                    
                    if let v = Float(value) {
                        self.dataFields.distanceValues[itemSetIndex] = v
                    }
                }
            )
            
            return TextField("0", text: b)
        } else {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.timeValues[itemSetIndex])"
                },
                set: { (value) in
                    self.dataFields.timeValues = self.dataFields.timeValues.map { $0 }
                    
                    if let v = Int(value) {
                        self.dataFields.timeValues[itemSetIndex] = v
                    }
                }
            )
            
            return TextField("0", text: b)
        }
    }
    
    func addSet() {
        dataFields.setsValue += 1
        dataFields.repsValues = dataFields.repsValues + [dataFields.defaultValueReps]
        dataFields.weightValues = dataFields.weightValues + [dataFields.defaultValueWeight]
        dataFields.timeValues = dataFields.timeValues + [dataFields.defaultValueTime]
        dataFields.distanceValues = dataFields.distanceValues + [dataFields.defaultValueDistance]
    }
    
    var exerciseFont: Font {
        .system(size: 20, weight: .medium)
    }
    
    var infoFont: Font {
        .system(size: 18)
    }
    
    var dictionary: ExerciseDictionary {
        // technically we allow for multiple exercise dictionaries for a given activity
        // but right now for routine based workouts we will assume only one exercise dictionary
        return exerciseTemplate.exerciseDictionaries.first!
    }
    
    var title: String {
        let tokens = dictionary.name.split(separator: "(")
        
        return tokens.first!.description
    }
    
    var subTitle: String? {
        let tokens = dictionary.name.split(separator: "(")
        
        if tokens.count > 1 {
            var s = tokens.last!.description
            s.removeLast()
            return s
        }
        
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(self.title).font(exerciseFont)
                
                if self.subTitle != nil {
                    Text("(\(self.subTitle!))")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                }
            }
            .padding(.bottom)
            
            VStack {
                HStack(spacing: 0) {
                    ForEach(self.activeFields, id: \.self) { item in
                        self.createColumnTitleViewFor(field: item)
                    }
                }
                .padding(.bottom, 8)
                
                ForEach(0..<self.dataFields.setsValue, id:\.self) { itemSetIndex in
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(self.activeFields, id: \.self) { item in
                            self.createColumnViewFor(field: item, itemSetIndex)
                        }
                    }
                }
            }
            
            Button(action: { self.addSet() }) {
                Text("ADD SET").font(.caption).padding(.top)
            }
        }
        .onAppear {
            self.activeFields = [.sets, .reps, .weight, .distance, .time].filter {
                self.exerciseTemplate.data.isActive(field: $0)
            }
            
            print(self.exerciseTemplate.exerciseDictionaries.first!.name)
            print([.sets, .reps, .weight, .distance, .time].filter {
                self.exerciseTemplate.data.isActive(field: $0)
            })
        }
    }
}
