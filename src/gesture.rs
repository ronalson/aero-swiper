use crate::Direction;

#[derive(Debug, Clone, Copy)]
pub struct GestureConfig {
    pub fingers: i32,
    pub min_horizontal_travel: f32,
    pub horizontal_bias: f32,
}

impl Default for GestureConfig {
    fn default() -> Self {
        Self {
            fingers: 3,
            min_horizontal_travel: 0.08,
            horizontal_bias: 1.2,
        }
    }
}

#[derive(Debug)]
pub struct GestureDetector {
    cfg: GestureConfig,
    active: bool,
    fired: bool,
    start_x: f32,
    start_y: f32,
}

impl GestureDetector {
    pub fn new(cfg: GestureConfig) -> Self {
        Self {
            cfg,
            active: false,
            fired: false,
            start_x: 0.0,
            start_y: 0.0,
        }
    }

    pub fn process_sample(&mut self, touch_count: i32, avg_x: f32, avg_y: f32) -> Option<Direction> {
        if touch_count != self.cfg.fingers {
            self.active = false;
            self.fired = false;
            return None;
        }

        if !self.active {
            self.active = true;
            self.fired = false;
            self.start_x = avg_x;
            self.start_y = avg_y;
            return None;
        }

        if self.fired {
            return None;
        }

        let dx = avg_x - self.start_x;
        let dy = avg_y - self.start_y;

        if dx.abs() < self.cfg.min_horizontal_travel {
            return None;
        }

        if dx.abs() <= dy.abs() * self.cfg.horizontal_bias {
            return None;
        }

        self.fired = true;
        if dx > 0.0 {
            Some(Direction::Next)
        } else {
            Some(Direction::Prev)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ignores_non_three_finger_samples() {
        let mut detector = GestureDetector::new(GestureConfig::default());
        assert_eq!(detector.process_sample(2, 0.2, 0.2), None);
        assert_eq!(detector.process_sample(4, 0.2, 0.2), None);
    }

    #[test]
    fn fires_next_for_right_swipe() {
        let mut detector = GestureDetector::new(GestureConfig::default());
        assert_eq!(detector.process_sample(3, 0.4, 0.4), None);
        assert_eq!(detector.process_sample(3, 0.51, 0.41), Some(Direction::Next));
    }

    #[test]
    fn fires_prev_for_left_swipe() {
        let mut detector = GestureDetector::new(GestureConfig::default());
        assert_eq!(detector.process_sample(3, 0.6, 0.4), None);
        assert_eq!(detector.process_sample(3, 0.49, 0.41), Some(Direction::Prev));
    }

    #[test]
    fn ignores_vertical_dominant_movement() {
        let mut detector = GestureDetector::new(GestureConfig::default());
        assert_eq!(detector.process_sample(3, 0.5, 0.2), None);
        assert_eq!(detector.process_sample(3, 0.58, 0.5), None);
    }

    #[test]
    fn fires_once_until_gesture_ends() {
        let mut detector = GestureDetector::new(GestureConfig::default());
        assert_eq!(detector.process_sample(3, 0.4, 0.4), None);
        assert_eq!(detector.process_sample(3, 0.51, 0.4), Some(Direction::Next));
        assert_eq!(detector.process_sample(3, 0.62, 0.4), None);
        assert_eq!(detector.process_sample(0, 0.0, 0.0), None);
        assert_eq!(detector.process_sample(3, 0.7, 0.4), None);
        assert_eq!(detector.process_sample(3, 0.58, 0.4), Some(Direction::Prev));
    }
}
