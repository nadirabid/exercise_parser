//
//  RoutinesViewerView.swift
//  client
//
//  Created by Nadir Muzaffar on 6/25/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI
import ASCollectionView

struct ExerciseFromTemplateView: View {
    var exerciseTemplate: ExerciseTemplate
    var viewWidth: CGFloat
    
    @State private var activeFields: [ExerciseField] = []
    
    func calculateWidthFor(field: ExerciseField) -> CGFloat {
        return viewWidth / CGFloat(activeFields.count)
    }
    
    func createColumnTitleViewFor(field: ExerciseField) -> some View {
        HStack {
            if activeFields.last == field {
                Spacer()
            }
            
            if activeFields.last == field {
                Text(field.description.uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.secondary)
            } else {
                Text(field.description.uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.secondary)
                    .frame(width: calculateWidthFor(field: field), alignment: .leading)
            }
        }
    }
    
    func createColumnViewFor(field: ExerciseField, _ itemSetIndex: Int) -> some View {
        HStack {
            if activeFields.last == field {
                Spacer()
            }
            
            if field == .sets {
                Text("\(itemSetIndex)")
                    .font(self.infoFont)
                    .frame(width: calculateWidthFor(field: field), alignment: .leading)
            } else if activeFields.last == field {
                Text(exerciseTemplate.data.defaultValueFor(field: field))
                    .font(self.infoFont)
            } else {
                Text(exerciseTemplate.data.defaultValueFor(field: field))
                    .font(self.infoFont)
                    .frame(width: calculateWidthFor(field: field), alignment: .leading)
            }
        }
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
                
                ForEach(1...self.exerciseTemplate.data.defaultValueSets, id:\.self) { itemSetIndex in
                    HStack(spacing: 0) {
                        ForEach(self.activeFields, id: \.self) { item in
                            self.createColumnViewFor(field: item, itemSetIndex)
                        }
                    }
                }
            }
            
            Text("ADD SET").font(.caption).padding(.top)
        }
        .onAppear {
            withAnimation(.none) {
                self.activeFields = [.sets, .reps, .weight, .distance, .time].filter {
                    self.exerciseTemplate.data.isActive(field: $0)
                }
            }
        }
    }
}

struct ExerciseTemplateView: View {
    var exerciseTemplate: ExerciseTemplate
    
    var labelFont: Font {
        .system(size: 9)
    }
    
    var title: String {
        let tokens = exerciseTemplate.exerciseDictionaries.first!.name.split(separator: "(")
        
        return tokens.first!.description
    }
    
    var subTitle: String? {
        let tokens = exerciseTemplate.exerciseDictionaries.first!.name.split(separator: "(")
        
        if tokens.count > 1 {
            var s = tokens.last!.description
            s.removeLast()
            return s
        }
        
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Text(title)
                
                if subTitle != nil {
                    Text(" - \(subTitle!)")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                }
            }
            
            HStack(spacing: 8) {
                if exerciseTemplate.data.sets {
                    HStack(spacing: 0) {
                        Text("sets / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("5")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if exerciseTemplate.data.reps {
                    HStack(spacing: 0) {
                        Text("reps / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("9")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if exerciseTemplate.data.weight {
                    HStack(spacing: 0) {
                        Text("lbs / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("135")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if exerciseTemplate.data.distance {
                    HStack(spacing: 0) {
                        Text("mi / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("2")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
                
                if exerciseTemplate.data.time {
                    HStack(spacing: 0) {
                        Text("time / ".uppercased())
                            .font(labelFont)
                            .foregroundColor(Color.secondary)
                            .fixedSize()
                        
                        Text("30s")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                }
            }
        }
    }
}

struct RoutineEditorView: View {
    @EnvironmentObject var exerciseDictionaryAPI: ExerciseDictionaryAPI
    
    @State private var exerciseTemplates: [ExerciseTemplate] = []
    @State private var selectExerciseDictionary: Bool = false
    
    func handleSelect(exerciseTemplates: [ExerciseTemplate]) {
        self.exerciseTemplates.append(contentsOf: exerciseTemplates)
        self.selectExerciseDictionary = false
    }
    
    func handleClose() {
        selectExerciseDictionary = false
    }
    
    var body: some View {
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = UIColor.systemBackground
        UITableView.appearance().showsVerticalScrollIndicator = false
        
        return VStack(spacing: 0) {
            VStack {
                HStack {
                    Button(action: {}) {
                        Text("Cancel")
                    }
                    .frame(width: 100, alignment: .leading)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Save")
                    }
                    .frame(width: 100, alignment: .trailing)
                    .disabled(self.exerciseTemplates.isEmpty)
                }
                .padding([.leading, .trailing])
                
                Divider()
            }
            
            
            if self.exerciseTemplates.isEmpty {
                VStack {
                    Spacer()
                    Text("No exercises").foregroundColor(Color.secondary)
                    Spacer()
                }
                .onAppear {
                    self.exerciseDictionaryAPI.getDictionaryList().then(on: DispatchQueue.main) { (paginatedResponse: PaginatedResponse<ExerciseDictionary>) in
                        let dictionaries = paginatedResponse.results
                        
                        self.exerciseTemplates = dictionaries.suffix(1000).prefix(7).map { d in
                            ExerciseTemplate(
                                data: ExerciseTemplateDataFields(
                                    sets: true,
                                    reps: true,
                                    weight: true,
                                    time: true,
                                    distance: false
                                ),
                                exerciseDictionaries: [d]
                            )
                        }
                    }
                }
            } else {
                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        ForEach(self.exerciseTemplates, id: \.cid) { item in
                            VStack {
                                ExerciseFromTemplateView(
                                    exerciseTemplate: item,
                                    viewWidth: geometry.size.width
                                )
                                .padding()
                                
                                Divider()
                            }
                            .listRowInsets(EdgeInsets())
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: { self.selectExerciseDictionary = true }) {
                    Text("Add exercise")
                        .foregroundColor(appColor)
                    
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(appColor)
                }
            }
            .padding([.leading, .trailing])
        }
        .sheet(isPresented: self.$selectExerciseDictionary) {
            VStack {
                ExerciseDictionaryListView(onSelectExerciseTemplates: self.handleSelect) {
                    self.selectExerciseDictionary = false
                }
                .environmentObject(self.exerciseDictionaryAPI)
            }
            .padding(.top)
            .animation(.default)
        }
    }
}

struct RoutinesViewerView: View {
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @EnvironmentObject var dictionariesAPI: ExerciseDictionaryAPI
    
    @Binding var disableCloseButton: Bool
    
    @State private var workouts: [Workout] = []
    @State private var createRoutine = true
    
    var body: some View {
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = feedColor.uiColor()
        UITableView.appearance().showsVerticalScrollIndicator = false

        return VStack {
            if createRoutine {
                RoutineEditorView()
            } else {
                VStack {
                    HStack {
                        Button(action: {
                            self.createRoutine = true
                        }) {
                            Text("Add")
                        }
                        
                        Spacer()
                    }
                    .padding(.leading)
                    
                    List {
                        ForEach(self.workouts, id: \.id) { workout in
                            WorkoutTemplateView(workout: workout)
                                .background(Color.white)
                                .buttonStyle(PlainButtonStyle())
                                .padding(.top)
                        }
                        .listRowInsets(EdgeInsets())
                        .animation(.none)
                        .background(feedColor)
                    }
                    .animation(.none)
                    .onAppear {
                        _ = self.workoutAPI.getUserWorkouts(page: 0, pageSize: 20) { (response) in
                            self.workouts.append(contentsOf: response.results)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

struct RoutinesViewerView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding<Bool>(
            get: { false },
            set: { _ in }
        )
        
        return RoutinesViewerView(disableCloseButton: binding)
    }
}
