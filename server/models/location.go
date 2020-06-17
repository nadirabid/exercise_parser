package models

import "github.com/golang/geo/s2"

type Location struct {
	Model
	Latitude   float64 `json:"latitude" gorm:"not null"`
	Longitude  float64 `json:"longitude" gorm:"not null"`
	WorkoutID  *uint   `json:"workout_id" gorm:"type:int REFERENCES workouts(id) ON DELETE CASCADE"` // TODO: remove??
	ExerciseID *uint   `json:"exercise_id"`
	Index      *int    `json:"index"`
}

func (Location) TableName() string {
	return "locations"
}

func (l *Location) IsZero() bool {
	return l.Latitude == 0.0 && l.Longitude == 0.0
}

// returns meters
func calculateTotalDistance(path []Location) float64 {
	if len(path) <= 2 {
		return 0
	}

	earthRadiusKm := 6371.0
	totalDistance := 0.0
	var last *s2.LatLng = nil
	for _, p := range path {
		latlng := s2.LatLngFromDegrees(p.Latitude, p.Longitude)
		if last == nil {
			last = &latlng
		} else if !(last.Lat == 0.0 && last.Lng == 0.0 && p.IsZero()) {
			totalDistance += earthRadiusKm * last.Distance(latlng).Radians()
		}
	}

	return totalDistance * 1000
}

// returns meters/s
func calculatePace(distanceMeters float64, seconds float64) float64 {
	if distanceMeters == 0 {
		return 0
	}

	if seconds == 0 {
		return 0
	}

	return distanceMeters / seconds
}
