//
//  Feed.swift
//  client
//
//  Created by Nadir Muzaffar on 3/1/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import Alamofire
import SwiftUI
import Combine

struct UserFeedView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var routeState: RouteState
    
    @EnvironmentObject var workoutAPI: WorkoutAPI
    @EnvironmentObject var metricAPI: MetricAPI
    
    @State private var feedDataPublisher: AnyCancellable? = nil
    @State private var feedData: PaginatedResponse<Workout>? = nil
    @State private var weeklyMetric: WeeklyMetricStats? = nil
    
    @State private var scrollViewContentOffset = CGFloat.zero
    @State private var height: CGFloat = 140
    
    var body: some View {
        return VStack(spacing: 0) {
            if self.feedData == nil {
                Spacer()
                HStack {
                    Spacer()
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                    Spacer()
                }
                Spacer()
            } else if self.feedData != nil {
                HStack(alignment: .center) {
                    Spacer()
                    Text(self.userState.userInfo?.getUserName() ?? "")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(Color.white)
                
                ZStack(alignment: .top) {
                    Color.clear // make ZStack expand to fill the content
                    
                    UserFeedViewHeader(
                        height: self.height,
                        scrollViewContentOffset: routeState.current == .userFeed ?
                            self.scrollViewContentOffset : 0,
                        weeklyMetric: self.weeklyMetric,
                        user: self.userState.userInfo
                    )
                        .zIndex(2)
                        .background(Color.white)
                    
                    if self.routeState.current == .userFeed {
                        if self.feedData?.results.count ?? 0 > 0 {
                            TrackableScrollView(.vertical, showIndicators: false, contentOffset: self.$scrollViewContentOffset) {
                                VStack(spacing: 0) {
                                    ForEach(self.feedData!.results) { workout in
                                        WorkoutView(user: self.userState.userInfo, workout: workout, showUserInfo: false)
                                            .background(Color.white)
                                            .padding(.top)
                                    }
                                }
                                .padding(.top, self.height)
                            }
                        } else {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("There's nothing in your feed!")
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    } else {
                        VStack {
                            Spacer()
                            
                            AggregateMuscleMetricsView(weeklyMetric: self.weeklyMetric)
                            
                            Spacer()
                        }
                        .padding(.top, self.height)
                    }
                }
            }
        }
        .background(self.feedData == nil ? Color.white : feedColor)
        .onAppear {
            self.workoutAPI.getUserWorkouts { (response) in
                self.feedData = response
            }
            
            self.metricAPI.getWeeklyStats { (response) in
                self.weeklyMetric = response
            }
        }
    }
}

struct UserFeedViewHeader: View {
    @EnvironmentObject var routeState: RouteState
    
    var height: CGFloat
    var scrollViewContentOffset: CGFloat
    var weeklyMetric: WeeklyMetricStats?
    var user: User?
    
    var secondsElapsed: String {
        if let seconds = weeklyMetric?.secondsElapsed {
            return secondsToElapsedTimeString(seconds)
        }
        
        return secondsToElapsedTimeString(0)
    }
    
    var sets: String {
        if let sets = weeklyMetric?.sets {
            return sets.description
        }
        
        return "0"
    }
    
    var reps: String {
        if let reps = weeklyMetric?.reps {
            return reps.description
        }
        
        return "0"
    }
    
    var distance: String {
        if let distance = weeklyMetric?.distance {
            var m = Measurement(value: Double(distance), unit: UnitLength.meters)
            
            if distance <= 300 {
                m = m.converted(to: UnitLength.feet)
            } else {
                m = m.converted(to: UnitLength.miles)
            }
            
            return Float(round(m.value*100)/100).description
        }
        
        return "0"
    }
    
    var distanceUnits: String {
        if let distance = weeklyMetric?.distance {
            if distance <= 300 {
                return UnitLength.feet.symbol
            } else {
                return UnitLength.miles.symbol
            }
        }
        
        return UnitLength.miles.symbol
    }
    
    func calculateButtonBarPositionFrom(size: CGSize) -> CGFloat {
        if routeState.current == .userFeed {
            return 0
        } else {
            return size.width / 2
        }
    }
    
    var calculatedHeight: CGFloat {
        if self.scrollViewContentOffset < 0 {
            return self.height - (self.scrollViewContentOffset / 3)
        }
        
        return max(self.height - self.scrollViewContentOffset, 50)
    }
    
    var userIconRadius: CGFloat {
        var radius: CGFloat = 65
        
        if self.scrollViewContentOffset < 0 {
            radius -= (self.scrollViewContentOffset / 12)
        } else {
            radius -= self.scrollViewContentOffset
        }
        
        radius = min(max(35, radius), 75)
        
        return radius
    }
    
    var userIconPadding: CGFloat {
        let padding: CGFloat = 20
        
        return min(max(5, padding - self.scrollViewContentOffset / 10), 35)
    }
    
    var body: some View {
        return VStack(spacing: 0) {
            Spacer()
            
            if self.scrollViewContentOffset < 40 {
                HStack(alignment: .center) {
                    UserIconShape()
                        .fill(Color.gray)
                        .padding(userIconPadding)
                        .background(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: self.userIconRadius, height: self.userIconRadius)
                        .padding([.leading, .trailing])
                    
                    VStack(alignment: .leading, spacing: 0) {
                        if self.scrollViewContentOffset < 5 {
                            Text("Last 7 days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .animation(.easeInOut)
                                .padding(.bottom, 3)
                                .opacity(1)
                                .animation(.easeInOut)
                                .transition(.scale)
                        }
                        
                        HStack(spacing: 10) {
                            WorkoutDetail(
                                name: "Time",
                                value: self.secondsElapsed
                            )
                            
                            Divider()
                            
                            WorkoutDetail(name: "Sets", value: self.sets)
                            
                            Divider()
                            
                            WorkoutDetail(name: "Reps", value: self.reps)
                        }
                        .fixedSize()
                    }
                    
                    Spacer()
                }
                .padding([.top, .bottom], min(15, 15 - self.scrollViewContentOffset / 6))
            }
            
            HStack(alignment: .center) {
                Spacer()
                
                Button(action: { self.routeState.current = .userFeed }) {
                    HeartIconShape()
                        .fill(self.routeState.current == .userFeed ? secondaryAppColor : Color.gray)
                        .frame(width: 20, height: 20)
                }
                
                Spacer()
                Spacer()
                
                Button(action: { self.routeState.current = .userMetrics }) {
                    ChartIconShape()
                        .fill(self.routeState.current == .userMetrics ? secondaryAppColor : Color.gray)
                        .frame(width: 20, height: 20)
                }
                
                Spacer()
            }
            .padding(.bottom)
            
            GeometryReader { geometry in
                Rectangle()
                    .fill(secondaryAppColor)
                    .position(x: self.calculateButtonBarPositionFrom(size: geometry.size))
                    .frame(width: geometry.size.width / 2, height: 2)
            }
            .frame(height: 1)
            
            Divider()
        }
        .frame(height: self.calculatedHeight)
    }
}

enum MetricsTimeRange: CaseIterable, Hashable {
    case Last7Days
    case Last30Days
    case Last90Days
    
    var description: String {
        switch self {
        case .Last7Days: return "Last 7 Days"
        case .Last30Days: return "Last 30 Days"
        case .Last90Days: return "Last 90 Days"
        }
    }
    
    var value: Int {
        switch self {
        case .Last7Days: return 7
        case .Last30Days: return 30
        case .Last90Days: return 90
        }
    }
}

extension MetricsTimeRange: Identifiable {
    var id: MetricsTimeRange { self }
}

struct AggregateMuscleMetricsView: View {
    @EnvironmentObject var metricAPI: MetricAPI
    
    var weeklyMetric: WeeklyMetricStats? = nil
    
    @State var metric: Metric? = nil
    @State var flattenedMuscles: [MetricMuscle] = []
    @State var metricsTimeRange: MetricsTimeRange = .Last7Days
    
    init(weeklyMetric: WeeklyMetricStats?) {
        self.weeklyMetric = weeklyMetric
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            .font: UIFont.boldSystemFont(ofSize: 12)
        ], for: .selected)
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            .font: UIFont.boldSystemFont(ofSize: 12)
        ], for: .normal)
    }
    
    func calculateActivation(_ reps: Int,  _ maxReps: Double, _ variance: Double) -> Double {
        // exp((x+1)*4.5) / 10000
        let x = Double(reps) / Double(maxReps)
        let constant = 1 - (exp(2 * 4.5) / 10000)
        let y = min(1.0, constant + exp((x + 1)*4.5) / 10000)
        
        print(x, constant, exp(9.0) / 10000, y)
        
        return y
    }
    
    var targetMuscles: [MuscleActivation] {
        let muscles = flattenedMuscles.filter { $0.usage == MuscleUsage.target.rawValue } ?? []
        
        print("TARGET MUSCLES")
        let minReps = Double(muscles.min(by: { $0.reps < $1.reps })?.reps ?? 0)
        let maxReps = Double(muscles.max(by: { $0.reps < $1.reps })?.reps ?? 0)
        let variance = (maxReps - minReps) / maxReps
        
        return muscles.reduce(into: []) { (result: inout [MuscleActivation], metricMuscle: MetricMuscle) in
            
            if let muscle = Muscle.from(name: metricMuscle.name) {
                print(muscle)
                result.append(MuscleActivation(
                    muscle: muscle,
                    activation: self.calculateActivation(metricMuscle.reps, maxReps, variance)
                ))
            }
        }
    }
    
    var synergistMuscles: [MuscleActivation] {
        let muscles = flattenedMuscles.filter { $0.usage == MuscleUsage.synergist.rawValue } ?? []
        
        let minReps = Double(muscles.min(by: { $0.reps < $1.reps })?.reps ?? 0)
        let maxReps = Double(muscles.max(by: { $0.reps < $1.reps })?.reps ?? 0)
        let variance = (maxReps - minReps) / maxReps
        
        print("SYNERGIST MUSCLES")
        
        return muscles.reduce(into: []) { (result: inout [MuscleActivation], metricMuscle: MetricMuscle) in
            if let muscle = Muscle.from(name: metricMuscle.name) {
                result.append(MuscleActivation(
                    muscle: muscle,
                    activation: self.calculateActivation(metricMuscle.reps, maxReps, variance)
                ))
            }
        }
    }
    
    func metricsTimeRangeChangeHandler(metricsTimeRange: MetricsTimeRange, _: MetricsTimeRange) {
        print("TIME RANGE CHANGED")
        self.metricAPI.getForPast(days: metricsTimeRange.value) { (metric) in
            self.metric = metric
            self.updateMuscleMetrics(from: metric.muscles)
        }
    }
    
    func updateMuscleMetrics(from metrics: [MetricMuscle]) {
        let flattenedMetrics = metrics.flatMap { (metric) -> [MetricMuscle] in
            if let muscle = Muscle.from(name: metric.name) {
                if muscle.isMuscleGroup {
                    return muscle.components.map {
                        MetricMuscle(name: $0.name, usage: metric.usage, reps: metric.reps)
                    }
                } else {
                    return [metric]
                }
            }
            
            return []
        }
        
        let groupedByUsage = Dictionary(grouping: flattenedMetrics, by: { $0.usage })
        
        self.flattenedMuscles = groupedByUsage.flatMap { (usage: String, metricsOfUsage: [MetricMuscle]) -> [MetricMuscle] in
            let groupedByName = Dictionary(grouping: metrics, by: { $0.name })
            
            return groupedByName.map { (name: String, metricsOfUsageAndName: [MetricMuscle]) -> MetricMuscle in
                let totalRepsForMuscleOfUsage = metricsOfUsageAndName.reduce(into: 0) { (result: inout Int, metric) in
                    result += metric.reps
                }
                
                return MetricMuscle(name: name, usage: usage, reps: totalRepsForMuscleOfUsage)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            Picker(
                selection: self.$metricsTimeRange.onChange(self.metricsTimeRangeChangeHandler),
                label: Text("Time range")
            ) {
                ForEach(MetricsTimeRange.allCases) { (range: MetricsTimeRange) in
                    VStack {
                        Text(range.description)
                            .fontWeight(.semibold)
                            .tag(range)
                    }
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            HStack(alignment: .center, spacing: 0) {
                AnteriorView(
                    activatedTargetMuscles: self.targetMuscles,
                    activatedSynergistMuscles: self.synergistMuscles
                )
                
                PosteriorView(
                    activatedTargetMuscles: self.targetMuscles,
                    activatedSynergistMuscles: self.synergistMuscles
                )
            }
            .frame(width: geometry.size.width)
        }
        .onAppear {
            self.metricAPI.getForPast(days: self.metricsTimeRange.value) { (metric) in
                self.metric = metric
                self.updateMuscleMetrics(from: metric.muscles)
            }
        }
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        return UserFeedView()
            .environmentObject(UserState())
            .environmentObject(EditableWorkoutState())
            .environmentObject(RouteState(current: .userFeed))
            .environmentObject(MockWorkoutAPI(userState: UserState()) as WorkoutAPI)
    }
}
#endif
