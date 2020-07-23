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
    var onDelete: () -> Void
    
    @ObservedObject private var dataFields: ExerciseTemplateData
    @State private var activeFields: [ExerciseField] = []
    @State private var showingActionSheet: Bool = false
    
    init(exerciseTemplate: ExerciseTemplate, viewWidth: CGFloat, onDelete: @escaping () -> Void = {}) {
        self.exerciseTemplate = exerciseTemplate
        self.viewWidth = viewWidth
        self.onDelete = onDelete
        self.dataFields = self.exerciseTemplate.data
    }
    
    func calculateWidthFor(field: ExerciseField) -> CGFloat {
        return (viewWidth - 40) / CGFloat(activeFields.count)
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
        .frame(width: field == activeFields.last ? nil : calculateWidthFor(field: field))
    }
    
    func createTextFieldFor(field: ExerciseField, itemSetIndex: Int) -> some View {
        if field == .reps {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.reps[itemSetIndex])"
                },
                set: { (value) in
                    self.dataFields.reps = self.dataFields.reps.map { $0 }
                    
                    if let v = Int(value) {
                        self.dataFields.reps[itemSetIndex] = v
                    }
                }
            )
            
            return TextField("0", text: b).font(.headline)
        } else if field == .weight {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.weight[itemSetIndex].format(f: ".0"))"
                },
                set: { (value) in
                    self.dataFields.weight = self.dataFields.weight.map { $0 }
                    
                    if let v = Float(value) {
                        self.dataFields.weight[itemSetIndex] = v
                    }
                }
            )
            
            return TextField("0", text: b).font(.headline)
        } else if field == .distance {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.distance[itemSetIndex].format(f: ".0"))"
                },
                set: { (value) in
                    self.dataFields.distance = self.dataFields.distance.map { $0 }
                    
                    if let v = Float(value) {
                        self.dataFields.distance[itemSetIndex] = v
                    }
                }
            )
            
            return TextField("0", text: b).font(.headline)
        } else {
            let b = Binding<String>(
                get: { () -> String in
                    "\(self.dataFields.time[itemSetIndex])"
                },
                set: { (value) in
                    self.dataFields.time = self.dataFields.time.map { $0 }
                    
                    if let v = Int(value) {
                        self.dataFields.time[itemSetIndex] = v
                    }
                }
            )
            
            return TextField("0", text: b).font(.headline)
        }
    }
    
    func addSet() {
        dataFields.sets += 1
        dataFields.reps = dataFields.reps + [dataFields.defaultValueReps]
        dataFields.weight = dataFields.weight + [dataFields.defaultValueWeight]
        dataFields.time = dataFields.time + [dataFields.defaultValueTime]
        dataFields.distance = dataFields.distance + [dataFields.defaultValueDistance]
        dataFields.calories = dataFields.calories + [dataFields.defaultValueCalories]
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
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(self.title).font(.subheadline)
                    
                    if self.subTitle != nil {
                        Text("(\(self.subTitle!))")
                            .font(.caption)
                            .foregroundColor(Color.secondary)
                    }
                }
                
                Spacer()
                    
                Button(action: { self.showingActionSheet = true }) {
                    Image(systemName:"ellipsis")
                        .background(Color.white)
                        .font(.headline)
                        .foregroundColor(Color.secondary)
                }
            }
            
            VStack {
                HStack(spacing: 0) {
                    ForEach(self.activeFields, id: \.self) { item in
                        self.createColumnTitleViewFor(field: item)
                    }
                    
                    HStack(alignment: .center) {
                        Image(systemName: "multiply")
                            .font(.caption)
                            .foregroundColor(Color.init(0, opacity: 0))
                    }
                    .padding(.leading)
                }
                
                ForEach(0..<self.dataFields.sets, id:\.self) { itemSetIndex in
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(self.activeFields, id: \.self) { item in
                            self.createColumnViewFor(field: item, itemSetIndex)
                        }
                        
                        Button(action: { self.dataFields.removeSetAt(index: itemSetIndex) }) {
                            HStack(alignment: .center) {
                                Image(systemName: "trash.fill")
                                    .font(.caption)
                                    .foregroundColor(Color.secondary)
                            }
                            .padding(.leading)
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
        }
        .actionSheet(isPresented: $showingActionSheet) {
            return ActionSheet(title: Text("Exercise actions"), buttons: [
                .destructive(Text("Delete")) {
                    self.onDelete()
                },
                .cancel()
            ])
        }
    }
}
