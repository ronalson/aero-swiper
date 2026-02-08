use aeroswiper::gesture::{GestureConfig, GestureDetector};
use aeroswiper::Direction;

#[test]
fn gesture_requires_three_fingers() {
    let mut detector = GestureDetector::new(GestureConfig::default());
    assert_eq!(detector.process_sample(2, 0.3, 0.3), None);
    assert_eq!(detector.process_sample(4, 0.3, 0.3), None);
}

#[test]
fn gesture_switches_after_min_distance() {
    let mut detector = GestureDetector::new(GestureConfig::default());
    assert_eq!(detector.process_sample(3, 0.2, 0.3), None);
    assert_eq!(detector.process_sample(3, 0.26, 0.31), None);
    assert_eq!(detector.process_sample(3, 0.31, 0.31), Some(Direction::Next));
}
